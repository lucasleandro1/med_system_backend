# frozen_string_literal: true

class MedicalShiftsReportPdf
  attr_reader :pdf, :items, :amount, :title, :email

  def initialize(pdf:, items:, amount:, title:, email:)
    @pdf = pdf
    @items = items
    @amount = amount
    @title = title
    @email = email
    @header_footer_height = 100
    @line_spacing = 15
    @text_box_padding = 10
    @right_text_offset = 110
  end

  def generate
    add_header
    add_body
    add_footer
  end

  private

  def add_header
    pdf.repeat(:all) do
      HeaderPdf.new(pdf: pdf, title: title, email: email).generate
    end
  end

  def add_footer
    pdf.repeat(:all, dynamic: true) do
      FooterPdf.new(pdf: pdf, amount: amount).generate
    end
  end

  def add_body
    pdf.move_down @line_spacing

    items.each do |item|
      start_new_page_if_needed
      pdf.stroke_horizontal_rule
      add_item_details(item)
      pdf.move_down @line_spacing
    end
  end

  def start_new_page_if_needed
    return unless pdf.cursor < @header_footer_height

    pdf.start_new_page
    add_header
  end

  def add_item_details(item)
    add_item_line(truncate_text(item.hospital_name), item_start_date(item))
    add_item_line(item_workload(item), item.amount.format)
    add_item_line(item_start_hour(item), item_paid?(item))
  end

  def add_item_line(left_text, right_text)
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      pdf.text_box left_text, at: [3, pdf.cursor - @text_box_padding], size: 10, align: :left
      pdf.text_box right_text, at: [pdf.bounds.width - @right_text_offset, pdf.cursor - @text_box_padding], size: 10,
        align: :right
    end
    pdf.move_down @line_spacing
  end

  def truncate_text(text, length = 35)
    text.length > length ? "#..." : text
  end

  def item_shift(item)
    item.shift == "Daytime" ? "Diurno" : "Noturno"
  end

  def item_workload(item)
    "#{item_shift(item)} - #{item.workload_humanize}"
  end

  def item_start_date(item)
    item.start_date.strftime("%d/%m/%Y")
  end

  def item_start_hour(item)
    "Início: #{item.start_hour.strftime('%H:%M')}"
  end

  def item_paid?(item)
    item.paid ? "Pago" : "A Receber"
  end
end
