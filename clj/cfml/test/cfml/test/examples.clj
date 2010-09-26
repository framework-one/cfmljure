(ns cfml.test.examples
	(:use [cfml.examples] :reload)
	(:use [clojure.test]))

(deftest test-greet
	(is "Hello Test!" (greet "Test")))

(deftest test-times-2-0
	(is 0 (times-2 0)))

(deftest test-times-2-1
	(is 2 (times-2 1)))

(deftest test-times-2-42
	(is 84 (times-2 42)))

(deftest test-twice-empty
	(is '() (twice '())))

(deftest test-twice-one
	(is '(2) (twice '(1))))

(deftest test-twice-lots
	(is '(0 2 4 6) (twice '(0 1 2 3))))
