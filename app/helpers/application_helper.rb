module ApplicationHelper
    def markdown(source)
        Kramdown::Document.new(source).to_html.html_safe
    end
    def displayPosts(source, arguments)
        content = liquidize(source, arguments)
        raw(Kramdown::Document.new(content).to_html)
    end
    def liquidize(content, arguments)
        Liquid::Template.parse(content).render(arguments, filters: [Tags])
    end
end
