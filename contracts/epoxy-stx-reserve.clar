;; @contract epoxy-stx-reserve
;; @version 1

(use-trait sip010-token .traits.epoxy-token)
(use-trait epoxy-token .traits.epoxy-token)

(define-data-var mint-epoxy-requests-id uint u0)

(define-map mint-epoxy-requests uint { 
    chain: (string-ascii 32), 
    recipient: principal, 
    chain-id: uint, 
    amount: uint, 
    bitcoin-header-hash: (buff 32),
    stacks-header-hash: (buff 32)
})

;; @description Transfer STX tokens to contracts, mint EPOXY in returns.
;; @param amount Amount of STX to transfer
;; @param token EPOXY's contract principal
;; @return Data that can be used for creating a proof
;; @technical
(define-public (mint-epoxy-on-stacks (amount uint) (token <epoxy-token>))
    (let ((request { chain: "Stacks", recipient: tx-sender, chain-id: u1, amount: amount })
          (request-id (register-mint-epoxy-request request token)))
        (print (merge request { type: "request::mint_epoxy", request-id: request-id }))
        (ok request)))

;; @description 
;; @param 
;; @return 
;; @technical
(define-public (mint-epoxy-on-ethereum (amount uint) (eth-address principal) (chain-id uint) (token <epoxy-token>))
    (let ((request { chain: "Ethereum", recipient: tx-sender, chain-id: chain-id, amount: amount })
          (request-id (register-mint-epoxy-request request token)))
        (print (merge request { type: "request::mint_epoxy", request-id: request-id }))
        (ok request-id)))

;; @description 
;; @param 
;; @return 
;; @technical
(define-public (mint-epoxy-on-optimism (amount uint) (eth-address principal) (chain-id uint) (token <epoxy-token>))
    (let ((request { chain: "Optimism", recipient: tx-sender, chain-id: chain-id, amount: amount })
          (request-id (register-mint-epoxy-request request token)))
        (print (merge request { type: "request::mint_epoxy", request-id: request-id }))
        (ok request-id)))

(define-private (register-mint-epoxy-request (request (tuple (chain (string-ascii 32)) (recipient principal) (chain-id uint) (amount uint))) (token <epoxy-token>))
    (let ((request-id (+ (var-get mint-epoxy-requests-id) u1)))
        (map-set mint-epoxy-requests request-id 
             (merge request {
                 bitcoin-header-hash: 0x00,
                 stacks-header-hash: 0x00,
             }))
        (var-set mint-epoxy-requests-id request-id)
        (try! (contract-call? token mint (get amount request) tx-sender))
        (try! (stx-transfer? (get amount request) tx-sender (as-contract tx-sender)))
        (ok request-id)))
