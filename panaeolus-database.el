(setq panaeolus-fn-database (make-hash-table :test 'equal))


(puthash "P" '((pat-name instrument(s) & threaded-body)) panaeolus-fn-database)

(puthash "demo" '((instrument)) panaeolus-fn-database)

(puthash "grid" '((beat-density-value)) panaeolus-fn-database)

(puthash "len" '((total-number-of-beats-in-seq)) panaeolus-fn-database)

(puthash "nuclear" '((:freq 40 :amp -12 :cutoff 500)) panaeolus-fn-database)

(puthash "organ" '((:freq 40 :amp -10)) panaeolus-fn-database)

(puthash "asfm" '((:freq 100 :amp -10)) panaeolus-fn-database)

(puthash "sweet" '((:freq 200 :amp -12)) panaeolus-fn-database)

(puthash "low_conga" '((:dur 1 :amp -12)) panaeolus-fn-database)

(puthash "mid_conga" '((:dur 1 :amp -12)) panaeolus-fn-database)

(puthash "high_conga" '((:dur 1 :amp -12)) panaeolus-fn-database)

(puthash "maraca" '((:dur 1 :amp -12)) panaeolus-fn-database)

(puthash "clap" '((:dur 1 :amp -12)) panaeolus-fn-database)

(puthash "sampler" '((:amp -12 :bank ["pan" "jb" "jx" "jv" "rash"])) panaeolus-fn-database)

(puthash "scan" '((:amp -12 :freq 440 :rate 0.01 :lpf 1200 :res 0.4 :lfo1 0 :lfo2 0 :lfo3 0 :lfo4 0 :type 1 :mass 3 :stif 0.01 :center 0.1 :damp -0.005 :pos 0 :y 0)) panaeolus-fn-database)

(puthash "tb303" '((:amp -16 :wave 4 :res 1.9 :dist 20 :att 0.03 :dec 0.1 :rel 0.1 :lpf 1.1 :filt 0)) panaeolus-fn-database)

(puthash "priest" '((:amp -12 :freq 200 :morph 1 :att 0.1 :format 70}})) panaeolus-fn-database)

(puthash "perc" '((:dur 0.4 :exp 0.1)) panaeolus-fn-database)

(puthash "delayl" '((:base 50 :layers 8 :ival 0.07 :shape 1 :scatter 0 :spread 0.5 :fback 0.95 :hpf 70 :lpf 70 :mode 1)) panaeolus-fn-database)

(puthash "flanger" '((:rate 5.15 :depth 0.001 :delay 0.001 :fback 0 :wet 1 :shape 1)) panaeolus-fn-database)

(puthash "lofi" '((:bits 6 :fold 0.1)) panaeolus-fn-database)

(puthash "freeverb" '((:room 0.9 :damp 0.35 :sr 44100)) panaeolus-fn-database)

(puthash "distort" '((:dist 0.5)) panaeolus-fn-database)

(puthash "butlp" '((:cutoff 1000)) panaeolus-fn-database)

(puthash "buthp" '((:cutoff 100)) panaeolus-fn-database)


(provide 'panaeolus-database)
