(ns task.test.create
  (:use [task.create] :reload)
  (:use [clojure.test]))

(deftest drop-create-drop-test
  (binding [*err* nil] (drop-tables)) ;; ensure tables do not exist & suppress exception output
  (is 
    (try
      (create-tables)
      true
      (catch Throwable e false)))
  (is
    (try
      (drop-tables)
      true
      (catch Throwable e false))))
