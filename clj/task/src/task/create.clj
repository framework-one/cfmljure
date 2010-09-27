(ns task.create
  (:use [clj-sql.core :as sql])
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