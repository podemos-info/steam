module Locomotive
  module Steam
    module Liquid
      module Tags
        module SEO

          class Base < ::Liquid::Tag

            def render_to_output_buffer(context, output)
              output << %{
                #{self.render_title(context)}
                #{self.render_metadata(context)}
              }
              output
            end

            protected

            def render_title(context)
              title = self.value_for(:seo_title, context)
              title = context['site'].name if title.blank?

              %{
                <title>#{title}</title>
              }
            end

            def render_metadata(context)
              %{
                <meta name="description" content="#{self.value_for(:meta_description, context)}">
                <meta name="keywords" content="#{self.value_for(:meta_keywords, context)}">
              }
            end

            # Removes whitespace and quote charactets from the input
            def sanitized_string(string)
              string ? string.strip.gsub(/"/, '') : ''
            end

            def value_for(attribute, context)
              object = self.metadata_object(context)
              value = object.try(attribute.to_sym).blank? ? context['site'].send(attribute.to_sym) : object.send(attribute.to_sym)
              self.sanitized_string(value)
            end

            def metadata_object(context)
              context['content_entry'] || context['page']
            end
          end

          class Title < Base

            # def render(context)
            def render_to_output_buffer(context, output)
              output << self.render_title(context)
              output
            end

          end

          class Metadata < Base

            # def render(context)
            def render_to_output_buffer(context, output)
              output << self.render_metadata(context)
              output
            end

          end

        end

        ::Liquid::Template.register_tag('seo'.freeze, SEO::Base)
        ::Liquid::Template.register_tag('seo_title'.freeze, SEO::Title)
        ::Liquid::Template.register_tag('seo_metadata'.freeze, SEO::Metadata)
      end
    end
  end
end
