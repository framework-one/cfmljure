(ns task.core
  (:use [clojure.java.jdbc :as sql :only (with-connection with-query-results insert-record)])
  (:use [task.db])
  (:use [clojure.string :as s :only (lower-case upper-case)]))

;; real generic methods start here...

(defn get-by-id 
  ([t id] (get-by-id t id identity))
  ([t id f] (get-by-id t id f :id))
  ([t id f idk] ;; need to handle zero / ambiguous rows
    (sql/with-connection db
      (sql/with-query-results rows
        [(str "select * from " (name t) " where " (name idk) " = ?") id]
        (f (first rows))))))

(defn get-all 
  ([t] (get-all t doall))
  ([t f] 
    (sql/with-connection db
      (sql/with-query-results rows
        [(str "select * from " (name t))]
        (f rows)))))

(defn add-record [t r]
  (sql/with-connection db
    (sql/insert-record t r)))

(defn- to-struct [r] (apply hash-map (mapcat (fn [[k v]] [(.replace (s/upper-case (name k)) \- \_) v]) r)))

(defn- to-record [m] (apply hash-map (mapcat (fn [[k v]] [(keyword (.replace (s/lower-case k) \_ \-)) v]) m)))

;; task-specific methods

(defn add-task [task-name]
  (add-record :task {:name task-name}))

(defn get-all-tasks []
  (map to-struct (get-all :task)))

(defn get-task-by-id [id]
  (to-struct (get-by-id :task id)))