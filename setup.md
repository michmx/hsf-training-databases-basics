---
title: Setup
---

# Using GitHub Codespaces (Recommended)

Simply click on the button below and then click on ``Create codespace``. The only requirement is a GitHub account.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/hsf-training/hsf-training-databases-basics)

You should have a new tab with VSCode running and everything pre-installed. The passwords for MYSQL and Opensearch will be ``HSFtraining1``.

The setup will be as if you followed Option 1 below, so you can test that everything is up and running by using.
```bash
docker exec -it myfirst-sqlserver bash -c "mysql -uroot -p"
```
and entering ``HSFtraining1`` as the password when prompted. You should see the mysql prompt as ``mysql>``. If yes, then everything is working.

You can type ``exit;`` in the mysql command prompt to exit.

You can skip the rest of this page.

# MYSQL setup

We recommend using a Docker container to run your first MySQL server. This is the easiest way to get started.

## Option 1: Use a Docker container

Please make sure you have docker installed and configured. You can follow the instructions at the
[Docker official documentation](https://docs.docker.com/get-docker/). To test your installation, execute
```bash
docker run hello-world
```

Once Docker is installed and configured, we will run a mySQL server using the
[official Docker image](https://hub.docker.com/_/mysql). We require to two ingredients to setup the MySQL server:
* A port number to communicate with the server. MySQL server uses port ``3306`` by default.
* A password for the root user.

Execute the following command to pull the image and run the MySQL server in a Docker container:
```bash
docker run -d --name=myfirst-sqlserver -p 3306:3306 --env="MYSQL_ROOT_PASSWORD=mypassword" mysql
```
Here we named the container as ``myfirst-sqlserver``. It is running on host ``localhost`` and port ``3306``.
A user with name ``root`` already exists with the password that you set in the environment variable ``MYSQL_ROOT_PASSWORD``.

:::{note} Port conflict issues
If you run into a port conflict issue (because the port is already in use, for example), then you can map the port
number to a different one. Something like port ``XXXX`` in ``-p XXXX:3306`` in the above Docker command.
:::

:::{note} Never use weak passwords in production!
Probably obvious, but this is a friendly reminder. Use [strong passwords](https://security.harvard.edu/use-strong-passwords)
when you are working with real data in databases that are accessible from outside your computer.
:::


To test that if everything is up and running, execute the following command:
```bash
docker exec -it myfirst-sqlserver bash -c "mysql -uroot -pmypassword"
```
you should see the mysql prompt as ``mysql>``. If yes, then everything is working.

You can type ``exit;`` in the mysql command prompt to exit.

:::{note} Stopping and starting the MySQL server
If you want to stop the Docker container that hosts MySQL server to continue working later, execute the following command:
```bash
docker stop myfirst-sqlserver
```
And the container will be stopped. To start the container again, execute the following command:
```bash
docker start myfirst-sqlserver
```

You can learn more about Docker commands at the [HSF Introduction to Docker and Podman](https://hsf-training.github.io/hsf-training-docker).
:::

## Option 2: Setup a MySQL server via Apptainer

If you are working on institutional computers, then you might not have the permission to install or run Docker.
In that case, you can use [Apptainer](https://apptainer.io/), which allows you to run containers in shared resources
without installing Docker. Chances are that you already have Apptainer available in institutional computers, check by
executing the following command:
```bash
apptainer --version
```

We will use the same image as in Option 1.
Appteiner images are readonly if overlayfs is not available, so we'll be mounting the socket and  database directories. This allows also for some persistency.
Depending on the system settings unprivileged Apptainer may not be allowed to bind to ports, so we'll use a socket file to connect to the server.
First move to a local directory: the image is not small and disk access will be faster, e.g. `mkdir /scratch/<username>/mysql-apptainer; cd /scratch/<username>/mysql-apptainer`.
Then execute the following commands to run the MySQL server in an Apptainer instance (replace mypassword with your password):
```bash
echo "SET PASSWORD FOR 'root'@'localhost' = 'mypassword';" > .mysqlrootpw
mkdir -p ./mysql/var/lib/mysql/ ./mysql/run/mysqld
apptainer pull --name mysql.sif docker://mysql
apptainer instance start --bind ${PWD} --bind ${PWD}/mysql/var/lib/mysql/:/var/lib/mysql --bind ${PWD}/mysql/run/mysqld:/run/mysqld  ./mysql.sif mysql
apptainer instance list    # just to make sure the instance started
apptainer exec instance://mysql mysqld --init-file=${PWD}/.mysqlrootpw &
```
If you don't run the last command in background the terminal will be used by the server console and you'll have to use another terminal for other commands.

To test that if everything is up and running, execute the following command:
```bash
apptainer exec instance://mysql mysql -S /var/run/mysqld/mysql.sock -u root -pmypassword
```
Remember to use it also throughout the tutorial instead of the docker command.

You may want to use a different password and a safer way to run mysql id to avoid to put the password in the command line, e.g. save in mysqlclient.ini the following:
```
[client]
password="mypassword"
```
And then run with (--defaults-extra-file must be the first option):
```bash
apptainer exec instance://mysql mysql --defaults-extra-file=myconf -S /var/run/mysqld/mysql.sock -u root
```

If you are interested on learning more about Apptainer, take a look at the
[HSF Training on Apptainer](https://hsf-training.github.io/hsf-training-singularity-webpage/)


## Option 3: Use a MySQL server on a remote machine

If you have access to a remote machine with a MySQL server (provided by your university or your laboratory),
then you can use that.


## Option 4: Use a MySQL/MariaDB server installed on your computer

If you want to install MySQL server on your computer, then you can follow the instructions at the
[official documentation](https://dev.mysql.com/doc/refman/8.2/en/installing.html).

Or you can use [MariaDB](https://mariadb.org/), which is an open source fork of MySQL. You can follow the instructions
at the [official documentation](https://mariadb.org/). At the time of writing this document, both basic MySQL and MariaDB
commands are compatible with each other.


# Opensearch setup

```bash
docker run -d -p 9200:9200 -p 9600:9600 -e "discovery.type=single-node" -e "OPENSEARCH_INITIAL_ADMIN_PASSWORD=<custom-admin-password>" opensearchproject/opensearch:latest
```

Replace: `<custom-admin-password>` to a secure password of your choice.

:::{note} Choosing a safe password
If you run with `-it` instead of `-d` and the password is not secure you will see the following message and the container will exit immediately.

```text
Password <your-admin-password> failed validation:

< reason for failure >

Please re-try with a minimum 8 character password and must contain at least one uppercase letter, one lowercase letter, one digit, and one special character that is strong. Password strength can be tested here: https://lowe.github.io/tryzxcvbn
```
:::

To test that if everything is up and running, execute the following command:
```bash
curl https://localhost:9200 -ku 'admin:<custom-admin-password>'
```
