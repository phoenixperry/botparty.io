# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Downloader do
  let(:nwo) { "pages-themes/primer" }
  let(:theme) { Jekyll::RemoteTheme::Theme.new(nwo) }
  subject { described_class.new(theme) }

  before { reset_tmp_dir }

  it "knows it's not downloaded" do
    expect(subject.downloaded?).to be_falsy
  end

  it "creates a zip file" do
    expect(subject.send(:zip_file)).to be_an_existing_file
  end

  context "downloading" do
    before { subject.run }
    after { FileUtils.rm_rf theme.root if Dir.exist?(theme.root) }

    it "knows it's downloaded" do
      expect(subject.downloaded?).to be_truthy
    end

    it "extracts the theme" do
      expect("#{theme.root}/_layouts/default.html").to be_an_existing_file
    end

    it "deletes the zip file" do
      expect(subject.send(:zip_file).path).to be_nil
    end

    it "knows the theme dir exists" do
      expect(subject.send(:theme_dir_exists?)).to be_truthy
    end

    it "knows the theme dir isn't empty" do
      expect(subject.send(:theme_dir_empty?)).to be_falsy
    end
  end

  context "with an invalid URL" do
    let(:zip_url) { "https://codeload.github.com/benbalter/_invalid_/zip/master" }
    before { allow(subject).to receive(:zip_url) { zip_url } }

    it "raises a DownloadError" do
      msg = "Request failed with 404 - Not Found"
      expect { subject.run }.to raise_error(Jekyll::RemoteTheme::DownloadError, msg)
    end
  end
end
