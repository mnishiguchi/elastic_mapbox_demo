module ApplicationHelper

  def set_title(title)
    provide(:title, title)
  end

  # Returns the full title on a per-page basis.
  def full_title(page_title="")
    base_title = "Apartment showoff"
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end
end
