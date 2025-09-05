;; Knowledge Preservation Network Smart Contract
;; A decentralized platform for documenting and preserving traditional knowledge and skills

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-KNOWLEDGE-NOT-FOUND (err u101))
(define-constant ERR-INVALID-INPUT (err u102))
(define-constant ERR-ALREADY-VOTED (err u103))
(define-constant ERR-INSUFFICIENT-STAKE (err u104))
(define-constant ERR-KNOWLEDGE-ALREADY-VERIFIED (err u105))

;; Data Variables
(define-data-var next-knowledge-id uint u1)
(define-data-var min-stake-amount uint u1000000) ;; 1 STX in micro-STX
(define-data-var verification-threshold uint u5) ;; Minimum votes for verification

;; Knowledge Entry Structure
(define-map knowledge-entries 
  uint 
  {
    contributor: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    category: (string-ascii 50),
    cultural-origin: (string-ascii 100),
    timestamp: uint,
    verified: bool,
    verification-votes: uint,
    reputation-score: uint,
    stake-amount: uint
  }
)

;; Knowledge Content (stored separately for gas efficiency)
(define-map knowledge-content
  uint
  {
    detailed-content: (string-utf8 2000),
    materials-needed: (string-ascii 300),
    step-by-step-process: (string-utf8 1500),
    cultural-significance: (string-utf8 800),
    preservation-notes: (string-utf8 500)
  }
)

;; Voting Records
(define-map verification-votes
  { knowledge-id: uint, voter: principal }
  { vote: bool, timestamp: uint }
)

;; Contributor Profiles
(define-map contributors
  principal
  {
    total-contributions: uint,
    verified-contributions: uint,
    reputation-points: uint,
    total-stake: uint,
    join-timestamp: uint
  }
)

;; Knowledge Categories
(define-map knowledge-categories
  (string-ascii 50)
  { count: uint, verified-count: uint }
)

;; Cultural Origins Registry
(define-map cultural-origins
  (string-ascii 100)
  { knowledge-count: uint, contributors: uint }
)

;; Staking Records
(define-map contributor-stakes
  { contributor: principal, knowledge-id: uint }
  { amount: uint, timestamp: uint }
)

;; Public Functions

;; Add new knowledge entry
(define-public (add-knowledge-entry 
    (title (string-ascii 100))
    (description (string-ascii 500))
    (category (string-ascii 50))
    (cultural-origin (string-ascii 100))
    (detailed-content (string-utf8 2000))
    (materials-needed (string-ascii 300))
    (step-by-step-process (string-utf8 1500))
    (cultural-significance (string-utf8 800))
    (preservation-notes (string-utf8 500))
    (stake-amount uint)
  )
  (let 
    (
      (knowledge-id (var-get next-knowledge-id))
      (current-contributor (default-to 
        { total-contributions: u0, verified-contributions: u0, reputation-points: u0, total-stake: u0, join-timestamp: u0 }
        (map-get? contributors tx-sender)
      ))
    )
    
    ;; Validate inputs
    (asserts! (>= stake-amount (var-get min-stake-amount)) ERR-INSUFFICIENT-STAKE)
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    
    ;; Transfer stake to contract
    (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))
    
    ;; Store knowledge entry
    (map-set knowledge-entries knowledge-id
      {
        contributor: tx-sender,
        title: title,
        description: description,
        category: category,
        cultural-origin: cultural-origin,
        timestamp: block-height,
        verified: false,
        verification-votes: u0,
        reputation-score: u0,
        stake-amount: stake-amount
      }
    )
    
    ;; Store knowledge content
    (map-set knowledge-content knowledge-id
      {
        detailed-content: detailed-content,
        materials-needed: materials-needed,
        step-by-step-process: step-by-step-process,
        cultural-significance: cultural-significance,
        preservation-notes: preservation-notes
      }
    )
    
    ;; Record stake
    (map-set contributor-stakes 
      { contributor: tx-sender, knowledge-id: knowledge-id }
      { amount: stake-amount, timestamp: block-height }
    )
    
    ;; Update contributor profile
    (map-set contributors tx-sender
      {
        total-contributions: (+ (get total-contributions current-contributor) u1),
        verified-contributions: (get verified-contributions current-contributor),
        reputation-points: (get reputation-points current-contributor),
        total-stake: (+ (get total-stake current-contributor) stake-amount),
        join-timestamp: (if (is-eq (get join-timestamp current-contributor) u0) 
                         block-height 
                         (get join-timestamp current-contributor))
      }
    )
    
    ;; Update category count
    (update-category-count category)
    
    ;; Update cultural origin count
    (update-cultural-origin-count cultural-origin)
    
    ;; Increment knowledge ID
    (var-set next-knowledge-id (+ knowledge-id u1))
    
    (ok knowledge-id)
  )
)

;; Vote for knowledge verification
(define-public (vote-for-verification (knowledge-id uint) (vote bool))
  (let 
    (
      (knowledge-entry (unwrap! (map-get? knowledge-entries knowledge-id) ERR-KNOWLEDGE-NOT-FOUND))
      (existing-vote (map-get? verification-votes { knowledge-id: knowledge-id, voter: tx-sender }))
    )
    
    ;; Check if already voted
    (asserts! (is-none existing-vote) ERR-ALREADY-VOTED)
    
    ;; Check if not already verified
    (asserts! (not (get verified knowledge-entry)) ERR-KNOWLEDGE-ALREADY-VERIFIED)
    
    ;; Record vote
    (map-set verification-votes 
      { knowledge-id: knowledge-id, voter: tx-sender }
      { vote: vote, timestamp: block-height }
    )
    
    ;; Update verification votes count if positive vote
    (if vote
      (begin
        (map-set knowledge-entries knowledge-id
          (merge knowledge-entry 
            { verification-votes: (+ (get verification-votes knowledge-entry) u1) }
          )
        )
        
        ;; Check if threshold reached for verification
        (if (>= (+ (get verification-votes knowledge-entry) u1) (var-get verification-threshold))
          (verify-knowledge-entry knowledge-id)
          (ok true)
        )
      )
      (ok true)
    )
  )
)

;; Internal function to verify knowledge entry
(define-private (verify-knowledge-entry (knowledge-id uint))
  (let 
    (
      (knowledge-entry (unwrap! (map-get? knowledge-entries knowledge-id) ERR-KNOWLEDGE-NOT-FOUND))
      (contributor (get contributor knowledge-entry))
      (current-contributor-data (unwrap! (map-get? contributors contributor) ERR-NOT-AUTHORIZED))
    )
    
    ;; Mark as verified
    (map-set knowledge-entries knowledge-id
      (merge knowledge-entry { verified: true, reputation-score: u100 })
    )
    
    ;; Update contributor verified count and reputation
    (map-set contributors contributor
      (merge current-contributor-data
        {
          verified-contributions: (+ (get verified-contributions current-contributor-data) u1),
          reputation-points: (+ (get reputation-points current-contributor-data) u100)
        }
      )
    )
    
    ;; Update category verified count
    (update-verified-category-count (get category knowledge-entry))
    
    ;; Return stake with bonus (10% bonus for verified knowledge)
    (let ((stake-return (+ (get stake-amount knowledge-entry) (/ (get stake-amount knowledge-entry) u10))))
      (as-contract (stx-transfer? stake-return tx-sender contributor))
    )
  )
)

;; Helper function to update category count
(define-private (update-category-count (category (string-ascii 50)))
  (let 
    (
      (current-data (default-to { count: u0, verified-count: u0 } (map-get? knowledge-categories category)))
    )
    (map-set knowledge-categories category
      (merge current-data { count: (+ (get count current-data) u1) })
    )
    (ok true)
  )
)

;; Helper function to update verified category count
(define-private (update-verified-category-count (category (string-ascii 50)))
  (let 
    (
      (current-data (unwrap! (map-get? knowledge-categories category) ERR-INVALID-INPUT))
    )
    (map-set knowledge-categories category
      (merge current-data { verified-count: (+ (get verified-count current-data) u1) })
    )
    (ok true)
  )
)

;; Helper function to update cultural origin count
(define-private (update-cultural-origin-count (cultural-origin (string-ascii 100)))
  (let 
    (
      (current-data (default-to { knowledge-count: u0, contributors: u0 } (map-get? cultural-origins cultural-origin)))
    )
    (map-set cultural-origins cultural-origin
      (merge current-data { knowledge-count: (+ (get knowledge-count current-data) u1) })
    )
    (ok true)
  )
)

;; Read-only functions

;; Get knowledge entry details
(define-read-only (get-knowledge-entry (knowledge-id uint))
  (map-get? knowledge-entries knowledge-id)
)

;; Get knowledge content
(define-read-only (get-knowledge-content (knowledge-id uint))
  (map-get? knowledge-content knowledge-id)
)

;; Get contributor profile
(define-read-only (get-contributor-profile (contributor principal))
  (map-get? contributors contributor)
)

;; Get category statistics
(define-read-only (get-category-stats (category (string-ascii 50)))
  (map-get? knowledge-categories category)
)

;; Get cultural origin statistics
(define-read-only (get-cultural-origin-stats (cultural-origin (string-ascii 100)))
  (map-get? cultural-origins cultural-origin)
)

;; Get current knowledge ID
(define-read-only (get-current-knowledge-id)
  (var-get next-knowledge-id)
)

;; Get verification threshold
(define-read-only (get-verification-threshold)
  (var-get verification-threshold)
)

;; Get minimum stake amount
(define-read-only (get-min-stake-amount)
  (var-get min-stake-amount)
)

;; Administrative functions (only contract owner)

;; Update verification threshold
(define-public (set-verification-threshold (new-threshold uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set verification-threshold new-threshold)
    (ok true)
  )
)

;; Update minimum stake amount
(define-public (set-min-stake-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set min-stake-amount new-amount)
    (ok true)
  )
)

;; Emergency withdrawal (only owner, in case of contract issues)
(define-public (emergency-withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (as-contract (stx-transfer? amount tx-sender CONTRACT-OWNER))
  )
)