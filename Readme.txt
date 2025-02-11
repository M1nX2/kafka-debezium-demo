1. Запустить 
docker-compose up -d
из корневой папки
2. Запустить
connectors.bat
после полной загрузки проекта
3. Выполнить sql код в файле ms-sql/init/sql для всех бд

Invoke-RestMethod -Uri "http://localhost:8083/connectors/products-connector-ms-sql/tasks/0/status"
Invoke-RestMethod -Uri "http://localhost:8083/connectors/products-sink-connector-ms-sql-replica/tasks/0/status"