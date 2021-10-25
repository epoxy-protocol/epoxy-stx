(impl-trait .traits.sip010-token)
(impl-trait .traits.epoxy-token)

;; Data
(define-fungible-token epoxy)
(define-data-var token-uri (string-utf8 256) u"")
(define-data-var contract-owner principal tx-sender)

;; Constants
(define-constant ERR-NOT-AUTHORIZED u1401)

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))

    (ok (var-set contract-owner owner))
  )
)

;; Trait implementation: sip010-token
(define-read-only (get-total-supply)
  (ok (ft-get-supply epoxy))
)

(define-read-only (get-name)
  (ok "Epoxy Token")
)

(define-read-only (get-symbol)
  (ok "EPOXY")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance epoxy account))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender (var-get contract-owner))
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (match (ft-transfer? epoxy amount sender recipient)
    response (begin
      (print memo)
      (ok response)
    )
    error (err error)
  )
)

;; Trait implementation: epoxy-token
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq contract-caller .epoxy-stx-reserve) (err ERR-NOT-AUTHORIZED))
    (ft-mint? epoxy amount recipient)
  )
)

(define-public (burn (amount uint) (sender principal))
  (begin
    (asserts! (is-eq contract-caller .epoxy-stx-reserve) (err ERR-NOT-AUTHORIZED))
    (ft-burn? epoxy amount sender)
  )
)
