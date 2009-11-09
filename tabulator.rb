
# Create tabular data in an easy-on-the-eyes format.
# Primarily useful for setting up test data within the test cases themselves.
#
# Typically you enhance TestCase with this module, eg,
#
#   require 'test/unit'
#   require 'tabulator'
#   class Test::Unit::TestCase
#     include Tabulator
#   end
#
# See Tabulator#tabulate
#
module Tabulator
  extend self

  # Transform a flat array into a table (array of hashes) using the first n 
  # elements as hash keys for each row, and converting the remaining elements
  # into their respective rows.
  #
  #  Eg,
  #  Tabulator.tabulate(2,
  #    [
  #      :route_number, :invoice_number,
  #      12,            123,
  #      12,            456,
  #      2,             765,
  #    ]
  #  ) do |row_hash|
  #    # This will be called three times, once for each apparent row
  #    puts row_hash[:route_number]
  #    puts row_hash[:invoice_number]
  #  end
  #
  def tabulate(column_count, array)
    validate_arguments column_count, array

    array = array.dup

    names = []
    column_count.times { names << array.shift }

    row_count = determine_row_count(column_count, array)

    rows = []
    row_count.times do 
      row = {}
      names.each do |name|
        row[name] = array.shift
      end
      if block_given?
        rows << yield(row)
      else
        rows << row
      end
    end
    rows
  end

  private

  def validate_arguments(column_count, array)
    raise "Bad column count: #{column_count.inspect}" unless column_count.is_a?(Integer)
    raise "Column count must be greater than 0" if column_count < 1
    if column_count > array.size
      raise "Wanted #{column_count} column headers, but array was only #{array.size} long"
    end
  end

  def determine_row_count(column_count, array)
    row_count = array.size / column_count
    if ((array.size.to_f / column_count) != row_count) 
      raise "Cannot tabulate #{array.size} elements using #{column_count} columns"
    end
    row_count
  end

end
