::Batch SSH Fast&Simple:
::Windows Open SSH
  @echo off
  :start
  cls
  echo Welcome to Incredible SSH!
  echo Click on any-key for start SSH connection...
  pause >nul
  (echo.|set /P="YourSshPasswordHere")| clip  
  echo SSH Connection with IncredibleVDS has been started!
  echo Click RMB + Enter for login in!
  cmd.exe /k ssh User@IP_Adress -p SshPort



::Exapmle:
  @echo off
  :start
  cls
  echo Welcome to Incredible SSH!
  echo Click on any-key for start SSH connection...
  pause >nul
  (echo.|set /P="123456789qwerty")| clip  
  echo SSH Connection with IncredibleVDS has been started!
  echo Click RMB + Enter for login in!
  cmd.exe /k ssh root@83.12.164.106 -p 22
