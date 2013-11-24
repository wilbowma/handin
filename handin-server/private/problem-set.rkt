#lang racket

(require racket/date "config.rkt")
(provide
  problem-set
  problem-set-name
  problem-set-dir
  problem-set-start
  problem-set-end

  problem-sets
  
  write-problem-sets!

  gen-problem-sets)

;; A ProblemSet is a (problem-set String Path Seconds Seconds)
;; dir should be an absolute path (i.e. as returned by
;; path->complete-path)
(struct problem-set (name dir start end) #:prefab)

;; A PS is a (list Path Second Second)
;; PS -> ProblemSet
(define (parse-ps ps) 
  (problem-set (path->name (first ps)) (first ps) (second ps) (third ps)))
(define (path->name p)
  (let-values ([(_1 name _2) (split-path p)])
    (path->string name)))

;; -> [List-of ProblemSet]
(define (problem-sets) (map parse-ps (get-conf 'problem-sets)))

;; [List-of ProblemSet] -> Void
;; writes the active and inactive sets to the server configuration file
;; TODO: This should use some sort of put-conf! that should exist in config.rkt
(define (write-problem-sets! pss)
  (let ([conf (filter (compose not (curry eq? 'problem-sets)) 
                (with-input-from-file config-file read))])
    (with-output-to-file 
      config-file
      (thunk (pretty-write (cons (list 'problem-sets (map problem-set->rawps pss)) conf)))
      #:exists 'replace)))

;; NB: Arg; part of the conversation process is in config.rkt and part
;; in here... But config can't depend on this file.
(define (problem-set->rawps ps)
  (list (problem-set-name ps)
        (seconds->datetimels (problem-set-start ps) #:maybe 0)
        (seconds->datetimels (problem-set-end ps) #:maybe FOREVER)))

(define (seconds->datetimels s #:maybe [maybe #f])
  (if (and maybe (= s maybe)) 
      #f
      (let ([d (seconds->date s)])
        (list (date-year d) (date-month d) (date-day d) (date-hour d) (date-minute d)))))

;; Seconds NaturalNumber -> [List-of ProblemSet]
;; Generates problem sets with dir (format "~a~a" prefix i) for i = 0
;; to n. The first problem set will become active on the date s and
;; remain active until exactly 7 days later.
(define (gen-problem-sets d n #:prefix [prefix "hw"])
  (let ([names (build-list n (compose (curry format "~a~a" prefix) 
                                      (lambda (x) (~a x #:width 2
                                                      #:align 'right
                                                      #:left-pad-string "0"))
                                      add1))]
        [start-dates (build-list n (lambda (n) (add-days d (* n 7))))]
        [end-dates (build-list n (lambda (n) (add-days d (* (add1 n) 7))))])
    (map (lambda (name start end) (problem-set name (path name) start end))
      names
      start-dates
      end-dates)))

;; TODO: test. srsly.

(define (add-days d days)
  (+ d (* days 24 60 60)))
