set -o errexit

bundle lock --add-platform x86_64-linux
bundle install
bundle exec rails assets:prercompile
bundle exec rails assets:clean
bundle exec rails db:migrate