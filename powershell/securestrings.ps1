# Plain text to secure strings
$Username = 'domain\username'
$Password = 'password'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$MySecureCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$pass

