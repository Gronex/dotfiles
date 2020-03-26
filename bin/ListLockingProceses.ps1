param($lockedFile)

$processes = Get-Process
foreach ($process in $processes)
{
  foreach ($module in $process.Modules)
  {
     if ($_.FileName -like "${lockedFile}*") 
     {
        $process.Name + " PID:" + $process.id + " [" + $module.Filename + "]"}
  }
}