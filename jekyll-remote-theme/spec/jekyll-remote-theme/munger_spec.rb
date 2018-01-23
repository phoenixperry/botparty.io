# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Munger do
  let(:source) { source_dir }
  let(:config) { { "source" => source } }
  let(:site) { make_site(config) }
  let(:theme_dir) { theme.root if theme }
  let(:layout_path) { File.expand_path "_layouts/default.html", theme_dir }
  let(:sass_dir) { File.expand_path "_sass/", theme_dir }
  let(:sass_path) { File.expand_path "jekyll-theme-primer.scss", sass_dir }
  let(:includes_dir) { File.expand_path "_includes/", theme_dir }
  let(:theme) { subject.send(:theme) }

  subject { described_class.new(site) }

  before { Jekyll.logger.log_level = :error }
  before { reset_tmp_dir }

  # Remove :after_reset hook to allow themes to be stubbed prior to munging
  before(:each) do
    hooks = Jekyll::Hooks.instance_variable_get("@registry")
    hooks[:site][:after_reset] = []
    Jekyll::Hooks.instance_variable_set("@registry", hooks)
  end

  it "stores the site" do
    expect(subject.site).to be_a(Jekyll::Site)
  end

  context "without a theme" do
    let(:source) { fixture_path("site-without-theme") }

    it "doesn't set a theme" do
      expect(site.theme).to_not be_a(Jekyll::RemoteTheme::Theme)
    end

    it "doesn't clone" do
      expect(layout_path).to_not be_an_existing_file
    end
  end

  context "with theme as a hash" do
    let(:config) { { "remote_theme" => { "foo" => "bar" } } }
    before { subject.munge! }

    it "doesn't set a theme" do
      expect(site.theme).to_not be_a(Jekyll::RemoteTheme::Theme)
    end

    it "doesn't clone" do
      expect(layout_path).to_not be_an_existing_file
    end
  end

  context "with a remote theme" do
    let(:config) { { "remote_theme" => "pages-themes/primer" } }
    before { subject.munge! }

    it "sets the theme" do
      expect(site.theme).to be_a(Jekyll::RemoteTheme::Theme)
      expect(site.theme.name).to eql("primer")
      expect(site.config["theme"]).to eql("primer")
    end

    it "downloads" do
      expect(layout_path).to be_an_existing_file
    end

    it "sets sass paths" do
      expect(sass_path).to be_an_existing_file
      expect(Sass.load_paths).to include(sass_dir)
    end

    it "sets include paths" do
      expect(site.includes_load_paths).to include(includes_dir)
    end

    it "sets layouts" do
      site.read
      expect(site.layouts["default"]).to be_truthy
      expect(site.layouts["default"].path).to eql(layout_path)
    end
  end
end
