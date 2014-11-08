test:
	gens --sandbox
	gens --checkFreeDriveSpace

help:
	gens -h

clean:
	@rm -f servers.txt
	@rm -rf *_autogen*
	@rm -f maintenance.sql
	@rm -rf o.tar.zip o.tar o
