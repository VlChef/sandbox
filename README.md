mkdir yourfolder
cd yourfolder
git clone https://github.com/VlChef/sandbox.git . 
### rm -rf ./.git/    (if you want to decouple from git repo)
bundle install

# create the kitchen
bundle exec kitchen create 
bundle exec kitchen login
