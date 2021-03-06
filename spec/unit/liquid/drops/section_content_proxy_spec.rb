require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::SectionContentProxy do

  let(:url_finder_service) { instance_double('UrlFinderService') }
  let(:services)  { instance_double('Services', url_finder: url_finder_service) }
  let(:site)      { instance_double('Site', default_locale: 'en') }
  let(:context)   { ::Liquid::Context.new({}, {}, { locale: 'en', services: services, site: site }) }
  let(:drop)      { described_class.new(content, settings).tap { |d| d.context = context } }

  describe 'text type setting' do

    let(:settings)  { [{ 'id' => 'title', 'type' => 'text' }] }
    let(:content)   { { 'title' => %(Click <a href="//locomotive/_locomotive-link/aaaa">here</a>) } }

    subject { drop.liquid_method_missing(:title) }

    it 'calls the url_finder_service to transform encoded links to existing urls' do
      expect(url_finder_service).to receive(:decode_urls_for).with(%(Click <a href="//locomotive/_locomotive-link/aaaa">here</a>)).and_return('done')
      is_expected.to eq 'done'
    end

    context 'the text is nil' do

      let(:content) { { 'title' => nil } }
      it { is_expected.to eq nil }

    end

  end

  describe 'integer type setting' do

    let(:settings)  { [{ 'id' => 'number', 'type' => 'integer' }] }
    let(:content)   { { 'number' => '42' } }

    subject { drop.liquid_method_missing(:number) }

    it 'converts the number into an integer' do
      is_expected.to eq 42
    end

    context 'the number is nil' do

      let(:content) { { 'number' => nil } }
      it { is_expected.to eq nil }

    end

  end

  describe 'url type setting' do

    let(:settings)  { [{ 'id' => 'link', 'type' => 'url' }] }
    let(:content)   { { 'link' => { 'type' => 'page', 'value' => 42, 'new_window' => true } } }
    let(:page)      { instance_double('Page') }

    context 'the link is not nil' do

      before do
        expect(url_finder_service).to receive(:url_for).with({ 'type' => 'page', 'value' => 42, 'new_window' => true }).and_return(['/foo/bar', true])
      end

      subject { drop.liquid_method_missing(:link).to_s }

      it 'returns the url to the page' do
        is_expected.to eq '/foo/bar'
      end

      context 'it knows if the link has to be opened in a new window or not' do

        subject { drop.liquid_method_missing(:link).new_window }

        it { is_expected.to eq true }

      end

      context 'it outputs the target="_blank" A attribute if new window is true' do

        subject { drop.liquid_method_missing(:link).new_window_attribute }

        it { is_expected.to eq('target="_blank"') }

      end

    end

    context 'the link is nil' do

      let(:content) { { 'link' => nil } }

      subject { drop.liquid_method_missing(:link) }

      it { is_expected.to eq nil }

    end

  end

  describe 'image picker type setting' do

    let(:settings)    { [{ 'id' => 'image', 'type' => 'image_picker' }] }
    let(:value)       { nil }
    let(:content)     { { 'image' => value } }
    let(:page)        { instance_double('Page') }
    let(:image_drop)  { drop.liquid_method_missing(:image) }

    subject { image_drop.to_s }

    it { is_expected.to eq '' }

    context 'the image is a string' do

      let(:value) { 'banner.jpg' }

      it { is_expected.to eq('banner.jpg') }

    end

    context 'the image is a hash' do

      let(:value) { { source: 'awesome_banner.jpg', cropped: 'cropped_awesome_banner.jpg', width: 42, height: 30 } }

      it { is_expected.to eq('cropped_awesome_banner.jpg') }

      it 'has access to the width and height of the image' do
        expect(image_drop.source).to eq('awesome_banner.jpg')
        expect(image_drop.cropped).to eq('cropped_awesome_banner.jpg')
        expect(image_drop.width).to eq(42)
        expect(image_drop.height).to eq(30)
      end

    end

    context 'the image is nil' do

      let(:value) { nil }

      subject { image_drop }

      it { is_expected.to eq nil }

    end

  end

end
