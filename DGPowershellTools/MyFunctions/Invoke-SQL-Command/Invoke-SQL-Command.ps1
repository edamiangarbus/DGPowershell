#
# Invoke_SQL_Command.ps1
#
function Invoke-SQL {
  param(
    [string] $dataSource = "Server\SQLInstance",
    [string] $database = "DBName",
    [string] $sqlCommand = $(throw "Please specify a query.")

  )


  $connectionString = "Data Source=$dataSource; Initial Catalog=$database; Integrated Security=True; ";


  $connection = new-object system.data.SqlClient.SQLConnection($connectionString);
  
  $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection);
  $connection.Open();

  $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command;
  $dataset = New-Object System.Data.DataSet;
  $adapter.Fill($dataSet) | Out-Null;

  $connection.Close();
  $dataSet.Tables;
}
