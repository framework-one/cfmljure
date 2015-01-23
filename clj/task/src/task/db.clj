(ns task.db)

(def db {:classname "org.apache.derby.jdbc.EmbeddedDriver"
         :subprotocol "derby"
         :subname "cfmljuretaskdb"
         :create true})
