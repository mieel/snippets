import argparse
import pysftp

def download_files_sftp(destination_path,remote_path,host_name,user,password,ext_filter):
    cnopts = pysftp.CnOpts()
    cnopts.hostkeys = None
    with pysftp.Connection(host=host_name, username=user, password=password, cnopts=cnopts) as sftp:
        print("Connection succesfully stablished ... ")
        sftp.cwd(remote_path)
        directory_structure = sftp.listdir_attr()    
        for attr in directory_structure:
            if attr.filename.endswith(ext_filter):
                print(f"Downloading: {attr.filename}")
                sftp.get(f"{remote_path}/{attr.filename}",f"{destination_path}\\{attr.filename}")
                print(f"Moving to {remote_path}/done")
                sftp.rename(f"{remote_path}/{attr.filename}",f"{remote_path}/done/{attr.filename}")
