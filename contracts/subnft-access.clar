(define-constant contract-owner tx-sender)
(define-constant subscription-duration u525600) ;; Duration in blocks
(define-constant subscription-price u1000000) ;; 1 STX

(define-data-var next-token-id uint u1)

(define-map token-owner { token-id: uint } principal)
(define-map token-expiry { token-id: uint } uint)
(define-map owner-token { user: principal } uint)

;; Mint a new subscription NFT
(define-public (mint-subscription)
  (let (
    (caller tx-sender)
    (token-id (var-get next-token-id))
    (expiry (+ stacks-block-height subscription-duration))
  )
    (begin
      ;; Check if user already has a subscription
      (asserts! (is-none (map-get? owner-token { user: caller })) (err u100))
      
      ;; Transfer payment to contract owner
      (try! (stx-transfer? subscription-price caller contract-owner))
      
      ;; Set token mappings
      (map-set token-owner { token-id: token-id } caller)
      (map-set token-expiry { token-id: token-id } expiry)
      (map-set owner-token { user: caller } token-id)
      
      ;; Increment token ID for next mint
      (var-set next-token-id (+ token-id u1))
      
      ;; Emit event
      (print { 
        event: "mint-subscription", 
        user: caller, 
        token-id: token-id,
        expiry: expiry
      })
      
      (ok token-id)
    )
  )
)

;; Renew an existing subscription NFT
(define-public (renew-subscription)
  (let (
    (caller tx-sender)
    (token-id-opt (map-get? owner-token { user: caller }))
  )
    (match token-id-opt token-id
      (let (
        (current-expiry-opt (map-get? token-expiry { token-id: token-id }))
      )
        (match current-expiry-opt current-expiry
          (let (
            ;; Use conditional instead of max function
            (base-time (if (> stacks-block-height current-expiry) stacks-block-height current-expiry))
            (new-expiry (+ base-time subscription-duration))
          )
            (begin
              ;; Transfer payment to contract owner
              (try! (stx-transfer? subscription-price caller contract-owner))
              
              ;; Update expiry
              (map-set token-expiry { token-id: token-id } new-expiry)
              
              ;; Emit event
              (print { 
                event: "renew-subscription", 
                user: caller, 
                token-id: token-id,
                expiry: new-expiry
              })
              
              (ok token-id)
            )
          )
          (err u103) ;; Token expiry not found
        )
      )
      (err u104) ;; No subscription found
    )
  )
)

;; Check if a user has an active subscription
(define-read-only (is-subscribed (user principal))
  (match (map-get? owner-token { user: user }) token-id
    (match (map-get? token-expiry { token-id: token-id }) expiry
      (> expiry stacks-block-height)
      false
    )
    false
  )
)

;; Get user's subscription details
(define-read-only (get-subscription (user principal))
  (match (map-get? owner-token { user: user }) token-id
    (match (map-get? token-expiry { token-id: token-id }) expiry
      (ok {
        token-id: token-id,
        expiry: expiry,
        active: (> expiry stacks-block-height),
        blocks-remaining: (if (> expiry stacks-block-height) (- expiry stacks-block-height) u0)
      })
      (err u105) ;; Token expiry not found
    )
    (err u106) ;; No subscription found
  )
)

;; Get token owner
(define-read-only (get-token-owner (token-id uint))
  (map-get? token-owner { token-id: token-id })
)

;; Get token expiry
(define-read-only (get-token-expiry (token-id uint))
  (map-get? token-expiry { token-id: token-id })
)

;; Get next token ID
(define-read-only (get-next-token-id)
  (var-get next-token-id)
)

;; Get subscription price
(define-read-only (get-subscription-price)
  subscription-price
)

;; Get subscription duration
(define-read-only (get-subscription-duration)
  subscription-duration
)

;; Admin function to withdraw contract balance (only contract owner)
(define-public (withdraw-balance)
  (let (
    (balance (stx-get-balance (as-contract tx-sender)))
  )
    (begin
      (asserts! (is-eq tx-sender contract-owner) (err u107))
      (as-contract (stx-transfer? balance tx-sender contract-owner))
    )
  )
)

;; Helper function to get the maximum of two uints
(define-read-only (get-max (a uint) (b uint))
  (if (> a b) a b)
)

;; Error codes:
;; u100: User already has a subscription
;; u101: Insufficient STX balance (deprecated)
;; u102: Insufficient STX balance for renewal (deprecated)
;; u103: Token expiry not found
;; u104: No subscription found for renewal
;; u105: Token expiry not found in get-subscription
;; u106: No subscription found in get-subscription
;; u107: Only contract owner can withdraw
