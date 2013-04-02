(ns task.create
  (:use [clojure.java.jdbc :as sql :only (with-connection create-table drop-table)])
  (:use [task.db]))

(defn create-tables []
  (sql/with-connection db
    (sql/create-table :task
      [:id :int "not null generated always as identity"]
      [:name "varchar(64)"])))

(defn drop-tables []
  (sql/with-connection db
    (try
      (sql/drop-table :task)
      (catch Throwable e nil))))