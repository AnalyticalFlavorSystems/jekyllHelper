module Kramdown
    module Converter
        class Html
            include ActionView::Helpers::AssetTagHelper

            def convert_img(el, indent)
                attrs = el.attr.dup
                link = attrs.delete 'src'
                image_tag ActionController::Base.helpers.asset_path(link), attrs
            end
        end
    end
end
module Tags
    class Liquid::Context
        def self.safe(safe = nil)
            if safe
                @safe = safe
            end
            @safe || false

        end
    end
    class HighlightBlock < Liquid::Block
        include Liquid::StandardFilters

        # The regular expression syntax checker. Start with the language specifier.
        # Follow that by zero or more space separated options that take one of three
        # forms: name, name=value, or name="<quoted list>"
        #
        # <quoted list> is a space-separated list of numbers
        SYNTAX = /^([a-zA-Z0-9.+#-]+)((\s+\w+(=(\w+|"([0-9]+\s)*[0-9]+"))?)*)$/

        def initialize(tag_name, markup, tokens)
            super
            if markup.strip =~ SYNTAX
                @lang = $1.downcase 
                @options = {}
                if defined?($2) && $2 != ''
                    # Split along 3 possible forms -- key="<quoted list>", key=value, or key
                    $2.scan(/(?:\w="[^"]*"|\w=\w|\w)+/) do |opt|
                        key, value = opt.split('=')
                        # If a quoted list, convert to array
                        if value && value.include?("\"")
                            value.gsub!(/"/, "")
                            value = value.split
                        end
                        @options[key.to_sym] = value || true
                    end
                end
                @options[:linenos] = "inline" if @options.key?(:linenos) and @options[:linenos] == true
            else
            end
        end
        def render(context)
            #prefix = context["highlighter_prefix"] || ""
            #suffix = context["highlighter_suffix"] || ""
            code = super.to_s.strip

            is_safe = true

            #output = case context.registers[:site].highlighter
            render_pygments(code, is_safe)

            #rendered_output = add_code_tag(output)
            #prefix + rendered_output + suffix
        end

        def sanitized_opts(opts, is_safe)
            if is_safe
                Hash[[
                    [:startinline, opts.fetch(:startinline, nil)],
                    [:hl_linenos,  opts.fetch(:hl_linenos, nil)],
                    [:linenos,     opts.fetch(:linenos, nil)],
                    [:encoding,    opts.fetch(:encoding, 'utf-8')],
                    [:cssclass,    opts.fetch(:cssclass, nil)]
                ].reject {|f| f.last.nil? }]
            else
                opts
            end
        end

        def render_pygments(code, is_safe)
            require 'pygments'

            @options[:encoding] = 'utf-8'

            highlighted_code = Pygments.highlight(
                code,
                :lexer   => @lang,
                :options => sanitized_opts(@options, is_safe)
            )

            if highlighted_code.nil?
            end

            highlighted_code
        end

        def render_rouge(code)
            require 'rouge'
            formatter = Rouge::Formatters::HTML.new(line_numbers: @options[:linenos], wrap: false)
            lexer = Rouge::Lexer.find_fancy(@lang, code) || Rouge::Lexers::PlainText
            code = formatter.format(lexer.lex(code))
            "<div class=\"highlight\"><pre>#{code}</pre></div>"
        end

        def render_codehighlighter(code)
            "<div class=\"highlight\"><pre>#{h(code).strip}</pre></div>"
        end
        def add_code_tag(code)
            code = code.sub(/<pre>\n*/,'<pre><code class="language-' + @lang.to_s.gsub("+", "-") + '" data-lang="' + @lang.to_s + '">')
            code = code.sub(/\n*<\/pre>/,"</code></pre>")
            code.strip
        end
    end




    class PostUrl < Liquid::Tag
        def initialize(tag_name, post, tokens)
            super
        end

        def render(context)

            return "#"
        end
    end

    class Picture < Liquid::Tag

        def initialize(tag_name, markup, tokens)
            @markup = markup
            super
        end

        def render(context)
            "<img src='http://placehold.it/350x150'>"
        end
    end
  Liquid::Template.register_tag('highlight', HighlightBlock)
  Liquid::Template.register_tag('post_url', PostUrl)
  Liquid::Template.register_tag('picture', Picture)
end
