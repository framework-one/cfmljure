(ns task.test.core
  (:use [task.core] :reload)
  (:use [task.create] :reload)
  (:use [clojure.test]))

(deftest add-test
  (binding [*err* nil] (drop-tables)) ;; ensure tables do not exist & suppress exception output
  (create-tables)
  (is (= 1 (add-task "First task")))
  (is (= 2 (add-task "Second task")))
  (let [tasks (get-all :task)
        ids (set (map :id tasks))]
    (is (= 2 (count tasks)))
    (is (= #{1 2} ids))))

(deftest get-by-id-test
  (binding [*err* nil] (drop-tables)) ;; ensure tables do not exist & suppress exception output
  (create-tables)
  (is (= 1 (add-task "First task")))
  (is (= 2 (add-task "Second task")))
  (let [t1 (get-by-id :task 1)
        t2 (get-by-id :task 2 identity)]
    (is (= 1 (:id t1)))
    (is (= "First task" (:name t1)))
    (is (= 2 (:id t2)))
    (is (= "Second task" (:name t2)))))

(deftest get-test
  (binding [*err* nil] (drop-tables)) ;; ensure tables do not exist & suppress exception output
  (create-tables)
  (is (zero? (get-all :task count)))
  (let [all (get-all-tasks)]
    (is (zero? (count all)))))
