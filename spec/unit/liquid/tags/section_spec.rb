require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Section do

  let(:services)      { Locomotive::Steam::Services.build_instance(nil) }
  let(:finder)        { services.section_finder }
  let(:source)        { 'Locomotive {% section header %}' }
  let(:live_editing)  { true }
  let(:context)       { ::Liquid::Context.new({}, {}, { services: services, live_editing: live_editing }) }

  before do
    allow(finder).to receive(:find).and_return(section)
  end

  describe 'rendering' do

    let(:definition) { {
      type:  'header',
      class: 'my-awesome-header',
      settings: [
        { id: 'brand', type: 'string', label: 'Brand' },
        { id: 'image', type: 'image_picker' }
      ],
      blocks: [
        { type: 'menu_item', settings: [
          { id: 'title', type: 'string' },
          { id: 'image', type: 'image_picker' }
        ]}
      ],
      default: {
        settings: { brand: 'NoCoffee', image: 'foo.png' },
        blocks: [{ id: 1, type: 'menu_item', settings: { title: 'Home', image: 'foo.png' } }] }
    }.deep_stringify_keys }

    let(:section) { instance_double(
      'Header',
      slug:           'header',
      type:           'header',
      liquid_source:  liquid_source,
      definition:     definition,
    )}

    subject { render_template(source, context) }

    context 'no blocks' do

      let(:liquid_source) { %(built by <a>\n\t<strong>{{ section.settings.brand }}</strong></a>) }

      it { is_expected.to eq %(Locomotive <div id="locomotive-section-header" class="locomotive-section my-awesome-header">built by <a>\n\t<strong data-locomotive-editor-setting="section-header.brand">NoCoffee</strong></a></div>) }

      context 'with a non string type input' do

        let(:liquid_source) { 'built by <strong>{{ section.settings.image }}</strong>' }

        it { is_expected.to eq 'Locomotive <div id="locomotive-section-header" class="locomotive-section my-awesome-header">built by <strong>foo.png</strong></div>' }

      end

      context 'without the live editing feature enabled' do

        let(:live_editing) { false }

        it { is_expected.to eq %(Locomotive <div id="locomotive-section-header" class="locomotive-section my-awesome-header">built by <a>\n\t<strong>NoCoffee</strong></a></div>) }

      end

    end

    context 'with blocks' do

      let(:liquid_source) { '{% for foo in section.blocks %}<a href="/">{{ foo.settings.title }}</a>{% endfor %}' }

      it { is_expected.to eq 'Locomotive <div id="locomotive-section-header" class="locomotive-section my-awesome-header"><a href="/" data-locomotive-editor-setting="section-header-block.0.title">Home</a></div>' }

      context 'with a non string type input' do

        let(:liquid_source) { '{% for foo in section.blocks %}<a>{{ foo.settings.image }}</a>{% endfor %}' }

        it { is_expected.to eq 'Locomotive <div id="locomotive-section-header" class="locomotive-section my-awesome-header"><a>foo.png</a></div>' }

      end

    end

    context 'rendering error (action) found in the section' do

      let(:live_editing)  { false }
      let(:liquid_source) { '{% action "Hello world" %}a.b(+}{% endaction %}' }
      let(:section)       { instance_double('section',
        liquid_source:  liquid_source,
        definition:     { settings: [], blocks: [] }
      )}

      it 'raises ParsingRenderingError' do
        expect { subject }.to raise_exception(Locomotive::Steam::ParsingRenderingError)
      end
    end

  end

end