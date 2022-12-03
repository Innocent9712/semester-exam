#!/usr/bin/env bash
sudo apt update -y;
sudo apt install postgresql postgresql-contrib -y;

# Create database
sudo -i -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$1"
cmd_res=$?
if [[ $cmd_res -ne 0 ]]; then
 sudo su - postgres -c "createdb $1";
fi

#edit postgres config file to allow user login with password
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     md5/' /etc/postgresql/*/main/pg_hba.conf
sudo systemctl restart postgresql

#create user
echo "\du" | sudo -i -u postgres psql | cut -d \| -f 1 | grep -qw "$2"
cmd_res=$?
if [[ $cmd_res -ne 0 ]]; then
 echo "CREATE USER $2 WITH PASSWORD '$3';" | sudo -i -u postgres psql;
fi

#grant user privilege to new database
echo "GRANT ALL PRIVILEGES on DATABASE $1 to $2" | sudo -i -u postgres psql;

#confirm that database and user exists and user has access to database
echo "\dl" | PGPASSWORD="$3" psql -U "$2" "$1"
