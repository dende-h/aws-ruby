require 'spec_helper'

listen_port = 80


# パッケージのインストール確認
%w{
  git make gcc-c++ patch openssl-devel libyaml-devel libffi-devel libicu-devel
  libxml2 libxslt libxml2-devel libxslt-devel zlib-devel readline-devel
  ImageMagick ImageMagick-devel epel-release nginx mysql-community-devel
}.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

# Mysqlインストール確認
describe command('mysql --version') do
  its(:stdout) { should match /mysql\s+Ver\s+8\.0\.34/ }
end

# unicornの確認
describe package('unicorn') do
  it { should be_installed.by('gem') }
end

# Nginxの起動状態
describe service('nginx') do
  it { should be_running }
end

#psコマンドを使ってUnicornのプロセスが実行しているかの確認をする
#unicorn master
describe command('ps aux | grep "unicorn master"') do
  its(:stdout) { should match /unicorn master/ }
end

#unicorn worker
describe command('ps aux | grep "unicorn worker" | wc -l') do
  its(:stdout) { should match /[3-9]|[1-9]\d+/ } # 3以上の任意の数
end

# rubyのバージョン確認
describe command('ruby -v') do
  its(:stdout) { should match /ruby 3\.1\.2/ }
end

# bundlerのバージョン確認
describe command('bundle -v') do
  its(:stdout) { should match /Bundler version 2\.3\.14/ }
end

# Railsのバージョン確認
describe command('rails -v') do
  its(:stdout) { should match /Rails 7\.0\.4/ } # ここに期待するバージョンを記述
end

# Nodeのバージョン確認
describe command('node -v') do
  its(:stdout) { should match /v17\.9\.1/ } # ここに期待するバージョンを記述
end

# yarnのバージョン確認
describe command('yarn -v') do
  its(:stdout) { should match /1\.22\.19/ } # ここに期待するバージョンを記述
end

# ポートが開かれているか
describe port(listen_port) do
  it { should be_listening }
end

# 指定されたURLに対してHTTPリクエストを送信し、レスポンスのHTTPステータスコードが200（成功）であることを確認するテスト。レスポンスボディの内容は確認せず、HTTPコードを対象とする。
describe command("curl http://13.231.108.50:#{listen_port}/ -o /dev/null -w '%{http_code}\n' -s") do
  its(:stdout) { should match /^200$/ }
end

describe command("curl http://Lecture10-alb-1385515351.ap-northeast-1.elb.amazonaws.com/ -o /dev/null -w '%{http_code}\n' -s") do
  its(:stdout) { should match /^200$/ }
end

# RDSのサーバー接続確認
describe 'MySQL Command' do
  host = 'lecture10-db.ckqxv4ruunm2.ap-northeast-1.rds.amazonaws.com'
  command_string = "nc -zv #{host} 3306"

  describe command(command_string) do
    its(:exit_status) { should eq 0 }
  end
end

# S3接続確認
describe command("aws s3 ls s3://lecture10s3bk") do
  its(:exit_status) { should eq 0 }
end
