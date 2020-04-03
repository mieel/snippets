if __name__ == '__main__':
    # Define arguments
    parser = argparse.ArgumentParser(description='Arguments')
    parser.add_argument('--source-path', metavar='path', required=True,
                        help='the path to download directory')
    parser.add_argument('--template-path', metavar='path', required=False,
                        default='none',help='the path to download directory')
    parser.add_argument('--target-table', required=True,
                        help='the remote path to fetch files from')
    parser.add_argument('--conn-string', required=True,
                        help='SQL database connection string e.g <SERVER=server-001;DATABASE=database_test;trusted_connection=yes')
    parser.add_argument('--exists-action', default='append', required=False,
                        choices=['append', 'replace'],
                        help='action when target table exists, default = append')
    args = parser.parse_args()
