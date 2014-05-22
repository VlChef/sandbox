mkdir yourfolder
cd yourfolder
git clone https://github.com/VlChef/sandbox.git . 
### rm -rf ./.git/    (if you want to decouple from git repo)
bundle install

# create the kitchen
bundle exec kitchen create 
bundle exec kitchen login

export EDITOR=vim
# create encrypted data bag
bundle exec knife solo data bag create admins generic --secret-file test/integration/encrypted_data_bag_secret_key

# show decrypted content of data bag "admins" data bag item "generic"
bundle exec knife solo data bag show admins generic --secret-file=test/integration/encrypted_data_bag_secret_key 

# edit databag
bundle exec knife solo data bag edit admins generic --secret-file test/integration/encrypted_data_bag_secret_key
