;;; scrape-flow.el --- Fetching training data from flow.polar.com

;; Author: Matti Uusitalo <uusitalo.matti@gmail.com>
;; Package-Requires ((dash "1.0") (ivy "1.0"))
;; Keywords: training

;;; Commentary:
;; This package provides scraping functions for fetching training data
;; from flow.polar.com.

;;; Code:

(require 'cl-macs)
(require 'dash)
(require 'dom)
(require 'json)
(require 'parse-time)
(require 'ivy)

(defgroup scrape-flow nil
  "Fetching data from polar flow."
  :group 'applications)

(defcustom scrape-flow-months
  '(("Jan" . 1)
    ("Feb" . 2)
    ("Mar" . 3)
    ("Apr" . 4)
    ("May" . 5)
    ("Jun" . 6)
    ("Jul" . 7)
    ("Aug" . 8)
    ("Sep" . 9)
    ("Oct" . 10)
    ("Nov" . 11)
    ("Dec" . 12))
    "Month names used in Polar Flow.
If you are using Flow in a language other than English, you can
add support by customizing this variable"
  :type '(alist :key-type string :value-type integer))

(defcustom scrape-flow-sports-translations
  '(("Juoksu" . "Juoksu")
    ("Juoksumatto" . "Juoksu")
    ("Maastopyöräily" . "Maastopyöräily")
    ("Muu sisäliikunta" . "Muu laji")
    ("Muu ulkoliikunta" . "Muu laji")
    ("Pyöräily" . "Pyöräily")
    ("Ratajuoksu" . "Juoksu")
    ("Vesijumppa" . "Muu laji")
    ("Voimaharjoittelu" . "Voimaharjoittelu")
    ("Aerobic" . "Jumppa")
    ("Allasuinti" . "Uinti")
    ("Alppihiihto" . "Muu laji")
    ("Amerikkalainen jalkapallo" . "Muu laji")
    ("Ampumahiihto" . "Hiihto")
    ("Avovesiuinti" . "Uinti")
    ("Baletti" . "Tanssi")
    ("Baseball" . "Muu laji")
    ("Body&Mind" . "Muu laji")
    ("Bootcamp" . "Muu laji")
    ("Core" . "Muu laji")
    ("Cross-trainer" . "Crosstrainer")
    ("Crossfit" . "Crossfit")
    ("Frisbeegolf" . "Frisbeegolf")
    ("Futsal" . "Muu laji")
    ("Golf" . "Golf")
    ("Hiihto" . "Hiihto")
    ("Hiihtosuunnistus" . "Hiihto")
    ("Hölkkä" . "Juoksu")
    ("Jalkapallo" . "Jalkapallo")
    ("Jazz" . "Tanssi")
    ("Jooga" . "Jooga")
    ("Judo" . "Kamppailulaji")
    ("Jääkiekko" . "Jääkiekko")
    ("Kajakkimelonta" . "Melonta")
    ("Kanoottimelonta" . "Melonta")
    ("Katutanssi" . "Tanssi")
    ("Kiipeily (sisä)" . "Kiipeily")
    ("Koripallo" . "Koripallo")
    ("Kriketti" . "Muu laji")
    ("Kuntokamppailulajit" . "Kamppailulaji")
    ("Kuntopiiri" . "Kuntopiiri")
    ("Kuntotanssi" . "Tanssi")
    ("Käsipallo" . "Muu laji")
    ("Kävely" . "Kävely")
    ("LES MILLS BODYATTACK" . "Jumppa")
    ("LES MILLS BODYBALANCE" . "Jumppa")
    ("LES MILLS BODYCOMBAT" . "Jumppa")
    ("LES MILLS BODYJAM" . "Jumppa")
    ("LES MILLS BODYPUMP" . "Jumppa")
    ("LES MILLS BODYSTEP" . "Jumppa")
    ("LES MILLS BODYVIVE" . "Jumppa")
    ("LES MILLS CXWORX" . "Jumppa")
    ("LES MILLS GRIT Cardio" . "Jumppa")
    ("LES MILLS GRIT Plyo" . "Jumppa")
    ("LES MILLS GRIT Strength" . "Jumppa")
    ("LES MILLS RPM" . "Jumppa")
    ("LES MILLS SH'BAM" . "Jumppa")
    ("LES MILLS SPRINT" . "Jumppa")
    ("LES MILLS THE TRIP" . "Jumppa")
    ("Lainelautailu" . "Muu laji")
    ("Latinalaistanssit" . "Tanssi")
    ("Leijalautailu" . "Muu laji")
    ("Lentopallo" . "Lentopallo")
    ("Liikkuvuusharjoitus (dynaaminen)" . "Venyttely")
    ("Liikkuvuusharjoitus (staattinen)" . "Venyttely")
    ("Luistelu" . "Luistelu")
    ("Luistelu (talvi)" . "Luistelu")
    ("Lumikenkäkävely" . "Lumikenkäily")
    ("Lumilautailu" . "Lumilautailu")
    ("Maahockey" . "Muu laji")
    ("Maantiejuoksu" . "Juoksu")
    ("Maantiepyöräily" . "Maantiepyöräily")
    ("Maastojuoksu" . "Maastojuoksu")
    ("Maastopyöräsuunnistus" . "Maastopyöräily")
    ("Nykytanssi" . "Tanssi")
    ("Nyrkkeily" . "Nyrkkeily")
    ("Off-piste-hiihto" . "Hiihto")
    ("Perinteinen hiihto" . "Perinteinen hiihto")
    ("Perinteinen rullahiihto" . "Rullahiihto")
    ("Pesäpallo" . "Muu laji")
    ("Pilates" . "Pilates")
    ("Pingis" . "Muu laji")
    ("Potkunyrkkeily" . "Kamppailulaji")
    ("Purjehdus" . "Muu laji")
    ("Purjelautailu" . "Muu laji")
    ("Pyörätuolikelaus" . "Muu laji")
    ("Rantalentopallo" . "Beach volley")
    ("Ratsastus" . "Ratsastus")
    ("Raviurheilu" . "Ratsastus")
    ("Rugby" . "Muu laji")
    ("Rullaluistelu (inline)" . "Rullaluistelu")
    ("Rullaluistelu (quad)" . "Rullaluistelu")
    ("Ryhmäliikunta" . "Jumppa")
    ("Salibandy" . "Salibandy")
    ("Sauvakävely" . "Sauvakävely")
    ("Seuratanssit" . "Tanssi")
    ("Showtanssi" . "Tanssi")
    ("Sisäpyöräily" . "Pyöräily")
    ("Sisäsoutu" . "Sisäsoutu")
    ("Soutu" . "Soutu")
    ("Spinning" . "Spinning")
    ("Squash" . "Squash")
    ("Steplautaharjoittelu" . "Jumppa")
    ("Sulkapallo" . "Sulkapallo")
    ("Suunnistus" . "Suunnistus")
    ("Tanssi" . "Tanssi")
    ("Telemark-hiihto" . "Hiihto")
    ("Tennis" . "Tennis")
    ("Toiminnallinen harjoittelu" . "Jumppa")
    ("Uinti" . "Uinti")
    ("Ultrajuoksu" . "Juoksu")
    ("Vaellus" . "Vaellus")
    ("Vapaa rullahiihto" . "Rullahiihto")
    ("Vapaahiihto" . "Hiihto")
    ("Venyttely" . "Venyttely")
    ("Vesihiihto" . "Muu laji")
    ("Vesilautailu" . "Muu laji")
    ("Voimistelu" . "Jumppa")
    ("Aqua fitness" . "Muu laji")
    ("Cycling" . "Pyöräily")
    ("Mountain biking" . "Maastopyöräily")
    ("Other indoor" . "Muu laji")
    ("Other outdoor" . "Muu laji")
    ("Running" . "Juoksu")
    ("Strength training" . "Voimaharjoittelu")
    ("Track&field running" . "Juoksu")
    ("Treadmill running" . "Juoksu")
    ("Aerobics" . "Jumppa")
    ("Backcountry skiing" . "Hiihto")
    ("Badminton" . "Sulkapallo")
    ("Ballet" . "Tanssi")
    ("Ballroom" . "Tanssi")
    ("Basketball" . "Koripallo")
    ("Beach volley" . "Beach volley")
    ("Biathlon" . "Hiihto")
    ("Boxing" . "Nyrkkeily")
    ("Canoeing" . "Melonta")
    ("Circuit training" . "Kuntopiiri")
    ("Classic XC skiing" . "Hiihto")
    ("Classic roller skiing" . "Rullahiihto")
    ("Climbing (indoor)" . "Kiipeily")
    ("Cricket" . "Muu laji")
    ("Dancing" . "Tanssi")
    ("Disc golf" . "Frisbeegolf")
    ("Downhill skiing" . "Muu laji")
    ("Field hockey" . "Muu laji")
    ("Finnish baseball" . "Muu laji")
    ("Fitness dancing" . "Tanssi")
    ("Fitness martial arts" . "Kamppailulaji")
    ("Floorball" . "Salibandy")
    ("Football" . "Jalkapallo")
    ("Freestyle XC skiing" . "Hiihto")
    ("Freestyle roller skiing" . "Rullahiihto")
    ("Functional training" . "Jumppa")
    ("Group exercise" . "Jumppa")
    ("Gymnastics" . "Jumppa")
    ("Handball" . "Muu laji")
    ("Hiking" . "Vaellus")
    ("Ice hockey" . "Jääkiekko")
    ("Ice skating" . "Luistelu")
    ("Indoor cycling" . "Pyöräily")
    ("Indoor rowing" . "Sisäsoutu")
    ("Inline skating" . "Luistelu")
    ("Jogging" . "Juoksu")
    ("Kayaking" . "Melonta")
    ("Kickboxing" . "Kamppailulaji")
    ("Kitesurfing" . "Muu laji")
    ("Latin" . "Tanssi")
    ("Mobility (dynamic)" . "Jumppa")
    ("Mobility (static)" . "Venyttely")
    ("Modern" . "Tanssi")
    ("Mountain bike orienteering" . "Maastopyöräily")
    ("Nordic walking" . "Sauvakävely")
    ("Open water swimming" . "Uinti")
    ("Orienteering" . "Suunnistus")
    ("Pool swimming" . "Uinti")
    ("Riding" . "Ratsastus")
    ("Road cycling" . "Pyöräily")
    ("Road running" . "Juoksu")
    ("Roller skating" . "Rullaluistelu")
    ("Rowing" . "Soutu")
    ("Sailing" . "Muu laji")
    ("Show" . "Tanssi")
    ("Skating" . "Luistelu")
    ("Ski orienteering" . "Hiihto")
    ("Skiing" . "Hiihto")
    ("Snowboarding" . "Lumilautailu")
    ("Snowshoe trekking" . "Lumikenkäily")
    ("Soccer" . "Jalkapallo")
    ("Step workout" . "Jumppa")
    ("Street" . "Tanssi")
    ("Stretching" . "Venyttely")
    ("Surfing" . "Muu laji")
    ("Swimming" . "Uinti")
    ("Table tennis" . "Muu laji")
    ("Telemark skiing" . "Hiihto")
    ("Trail running" . "Maastojuoksu")
    ("Trotting" . "Ratsastus")
    ("Ultra running" . "Juoksu")
    ("Volleyball" . "Lentopallo")
    ("Wakeboarding" . "Muu laji")
    ("Walking" . "Kävely")
    ("Water skiing" . "Muu laji")
    ("Wheelchair racing" . "Muu laji")
    ("Windsurfing" . "Muu laji")
    ("Yoga" . "Jooga"))
  "Polar sport name translations."
  :type '(alist :key-type string :value-type string))

(defcustom scrape-flow--sport-indicators
  '(("https://platform.cdn.polar.com/ecosystem/sport/icon/808d0882e97375e68844ec6c5417ea33-2015-10-20_13_46_22" . "Running")
    ("https://platform.cdn.polar.com/ecosystem/sport/icon/e6a478c45077351e49d836f8623978bb-2015-10-20_13_46_05" . "Track&field running")
    ("https://platform.cdn.polar.com/ecosystem/sport/icon/4ddd474b10302e72fb53bbd69028e15b-2015-10-20_13_46_17" . "Mountain biking")
    ("https://platform.cdn.polar.com/ecosystem/sport/icon/7c2ea21441d07645c08df51ee9509c4d-2015-10-20_13_45_52" . "Circuit training")
    ("https://platform.cdn.polar.com/ecosystem/sport/icon/561a80f6d7eef7cc328aa07fe992af8e-2015-10-20_13_46_03" . "Cycling"))
  "Polar flow icons urls can be used to identify the sport."
  :type '(alist :key-type string :value-type string))

(defcustom scrape-flow-get-training-action
  'scrape-flow--default-fetch-action
  "Action that is performed after fetching a training from polar flow."
  :type 'function)

(defun scrape-flow--default-fetch-action (training)
  "Insert TRAINING, pretty printed to the current buffer."
  (insert (pp-string training)))

(defun scrape-flow--seconds-to-string (time)
  "Return TIME as a readable string."
  (let* ((minutes (/ time 60))
         (seconds (% time 60)))
    (format "%02d'%02d" minutes seconds)))

(defun scrape-flow--pace-to-string (pace)
  "Return PACE as readable string."
  (let* ((minutes (/ pace 60))
         (seconds (% pace 60)))
    (format "%02d'%02d / km" minutes seconds)))

(defun scrape-flow--fetch-html (url)
  "Fetch html page from URL."
  (with-current-buffer (url-retrieve-synchronously url)
    (goto-char 0)
    (forward-paragraph)
    (libxml-parse-html-region (point) (point-max))))

(defun scrape-flow--front-page ()
  "Retrieve the polar flow front page."
  (url-retrieve-synchronously "https://flow.polar.com"))

(defun scrape-flow-logged-p ()
  "Return non-nil when logged in to polar flow."
  (let ((dom (scrape-flow--fetch-html "https://flow.polar.com")))
    (not (dom-by-id dom "loginButtonNav"))))

;;;###autoload
(defun scrape-flow-login ()
  "Log in to Polar Flow, unless already logged in."
  (interactive)
  (unless (scrape-flow-logged-p)
    (let* ((user-name (read-string "Polar flow user name"))
           (password (read-passwd "Polar flow password")))
      (url-retrieve-synchronously "https://flow.polar.com/login")
      (let ((url-request-method "POST")
            (url-request-extra-headers
             '(("Content-Type" . "application/x-www-form-urlencoded")))
            (url-request-data
             (mapconcat (lambda (arg)
                          (concat (url-hexify-string (car arg))
                                  "="
                                  (url-hexify-string (cdr arg))))
                        `(("email" . ,user-name) ("password" . ,password))
                        "&")))
        (url-retrieve-synchronously "https://flow.polar.com/login")))))

(defun scrape-flow--list-exercises (start-month start-year end-month end-year)
  "Retrieve a list of exercices.
Limits the exercises between START-MONTH, START-YEAR and END-MONTH, END-YEAR"
  (with-current-buffer
      (url-retrieve-synchronously
       (format "https://flow.polar.com/training/getCalendarEvents?start=1.%d.%d&end=1.%d.%d" start-month start-year end-month end-year))
    (goto-char 0)
    (forward-paragraph)
    (json-read)))

(defun scrape-flow--get-url (exercise)
  "Return web url to the EXERCISE."
  (format "https://flow.polar.com%s" (alist-get 'url exercise)))

(defun scrape-flow--get-bdp (dom id)
  "Return value from DOM inside a tag with ID."
  (-some-> dom
    (dom-by-id id)
    (dom-children)
    (car)))

(defun scrape-flow--get-distance (dom)
  "Return distance from DOM.
Expects the unit to be in meters.
TODO: unit conversion"
  (* 1000
     (string-to-number
      (scrape-flow--get-bdp dom "^BDPDistance$"))))

(defun scrape-flow--get-avg-hr (dom)
  "Return avg hr from DOM."
  (string-to-number
   (scrape-flow--get-bdp dom "^BDPHrAvg$")))

(defun scrape-flow--get-avg-pace (dom)
  "Return average pace (in seconds / km) from DOM.
Expects the unit to be min / km
TODO: unit conversion"
  (-let (((minutes seconds)
          (-some--> dom
            (scrape-flow--get-bdp it "^BDPPaceAvg$")
            (split-string it ":")
            (mapcar 'string-to-number it))))
    (+ (* 60 minutes) seconds)))

(defun scrape-flow--get-duration (dom)
  "Return duration (in seconds) from DOM."
  (-let (((hours minutes seconds)
          (-some--> dom
            (dom-by-id it "^duration$")
            (dom-attr it 'value)
            (split-string it ":")
            (mapcar 'string-to-number it))))
    (+ (* 60 60 hours) (* 60 minutes) seconds)))

(defun scrape-flow--get-sport (dom)
  "Return sport from DOM."
  (string-trim
   (scrape-flow--get-bdp dom "^sportHeading$")))

(defun scrape-flow--get-exercise-time (dom)
  "Return exercise time from DOM."
  (-let* (((_ _ month day _ year time _ _)
           (-some--> dom
             (dom-by-id it "^sportHeading$")
             (dom-children it)
             (nth 2 it)
             (string-trim it)
             (split-string it "|")
             (car it)
             (split-string it "[,\s]")))

          ((hour minute)
           (split-string time ":")))

    (encode-time
     0
     (string-to-number minute)
     (string-to-number hour)
     (string-to-number day)
     (cdr (assoc month scrape-flow-months))
     (string-to-number year))))

(defun scrape-flow--fetch-exercise (url)
  "Fetch exercise from Polar Flow URL."
  (with-current-buffer (url-retrieve-synchronously url)
    (goto-char 0)
    (forward-paragraph)
    (libxml-parse-html-region (point) (point-max))))

(defun scrape-flow--get-ascent (dom)
  "Read ascent from DOM.
Expects the units to be meters.
TODO: unit conversion"
  (-some-> dom
       (dom-by-class "ASCENT")
       (dom-by-class "basic-data-panel__value-container")
       (dom-children )
       (car)
       (string-to-number)))

(defun scrape-flow--parse-exercise (dom)
  "Scrape exercise from DOM."
  `((time . ,(scrape-flow--get-exercise-time dom))
    (sport . ,(scrape-flow--get-sport dom))
    (duration . ,(scrape-flow--get-duration dom))
    (distance . ,(scrape-flow--get-distance dom))
    (avg-hr . ,(scrape-flow--get-avg-hr dom))
    (avg-pace . ,(scrape-flow--get-avg-pace dom))
    (ascent . ,(scrape-flow--get-ascent dom))))

(defun scrape-flow--identify-sport (suggestion)
  "Identify sport from the image url of the SUGGESTION."
  (-some-> (alist-get 'iconUrl suggestion)
    (assoc  scrape-flow--sport-indicators)
    (cdr)))

(defun scrape-flow--render-for-ivy (suggestion)
  "Render SUGGESTION for ivy."
  (format "%s | %s | %s"
          (alist-get 'datetime suggestion)
          (scrape-flow--identify-sport suggestion)
          (scrape-flow--seconds-to-string (/ (alist-get 'duration suggestion) 1000))))

(defun scrape-flow--choose-selected (selection exercises)
  "Return choice designated by SELECTION from EXERCISES."
  (car
   (seq-filter
    (lambda (m) (string= selection (scrape-flow--render-for-ivy m))) exercises)))

(defun scrape-flow--fetch-exercise-summary (url)
  "Fetch and parse exercise summary from URL."
  (->> (scrape-flow--fetch-exercise url)
       (scrape-flow--parse-exercise)
       (cons `(url . ,url))))

(defun scrape-flow--get-laps (exercise-id)
  "Retrieve lap data for EXERCISE-ID."
  (with-current-buffer
      (let ((url-request-method "POST")
            (url-request-extra-headers
             '(("Content-Type" . "application/json; charset=utf-8")))
            (url-request-data
             (json-encode `((exeId . ,exercise-id)
                            (type . "man")))))
        (url-retrieve-synchronously "https://flow.polar.com/training/getLaps"))
    (goto-char 0)
    (forward-paragraph)
    (ignore-errors                      ; If no laps, there's nothing to read
      (json-read))))

;;;###autoload
(defun scrape-flow-get-training ()
  "Get training from polar flow and forward it to `scrape-flow-get-training-action`.
Training data is an alist with the following keys:

 - time       ; Emacs internal time
 - sport      ; sport name as string
 - duration   ; duration in seconds, number
 - distance   ; distance in meters, number
 - avg-hr     ; average heart rate, number
 - avg-pace   ; average pace as seconds per kilometer, number
 - ascent     ; ascent in meters, number
 - url        ; link to the training details, string"
  (interactive)
  (-let* (((_ _ _ _ this-month this-year) (decode-time (current-time)))
          (year (read-number "year: " this-year))
          (month (read-number "month: " this-month))
          (exercises (scrape-flow--list-exercises
                      month
                      year
                      (if (= month 12) 1 (1+ month))
                      (if (= month 12) (1+ year) year))))
    (ivy-read "Choose exercise: "
              (mapcar 'scrape-flow--render-for-ivy exercises)
              :require-match t
              :caller 'scrape-flow-get-training
              :initial-input (format-time-string "^%Y-%02m-%02dT" (current-time))
              :action (lambda (x)
                        (let* ((selection (scrape-flow--choose-selected x exercises))
                               (url (format "https://flow.polar.com%s"
                                            (alist-get 'url selection)))
                               (exercise-id (alist-get 'listItemId selection)))
                          (->> (scrape-flow--fetch-exercise url)
                               (scrape-flow--parse-exercise)
                               (cons `(url . ,url))
                               (funcall scrape-flow-get-training-action)))))))

(provide 'scrape-flow)
;;; scrape-flow.el ends here
