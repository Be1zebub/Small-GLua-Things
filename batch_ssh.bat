::incredible-gmod.ru
::Batch SSH Fast&Simple:

  @echo off
  :start
  cls
  echo Welcome to Incredible SSH!
  echo Click on any-key for start SSH connection...
  pause >nul
  cls
  (echo.|set /P="YourSshPasswordHere")| clip  ::This copies your ssh password to the clipboard (don't forget to clear it :) )
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
  cls
  (echo.|set /P="123456789qwerty")| clip  
  echo SSH Connection with IncredibleVDS has been started!
  echo Click RMB + Enter for login in!
  cmd.exe /k ssh root@83.12.164.106 -p 22
