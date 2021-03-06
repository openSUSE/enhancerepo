# Encoding: utf-8

#--
#
# enhancerepo is a rpm-md repository metadata tool.
# Copyright (C) 2008, 2009 Novell Inc.
# Author: Duncan Mac-Vicar P. <dmacvicar@suse.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.  A copy of the GNU General Public License is
# also available at http://www.gnu.org/copyleft/gpl.html.
#
#++
#
require_relative 'helper'
require 'stringio'
require 'zlib'

class Primary_test < Minitest::Test
  def setup
    #	  $stderr << "Primary_test"
  end

  def test_xml_output
    primary = EnhanceRepo::RpmMd::Primary.new(test_data('rpms/repo-1'))
    primary.read_packages

    assert !primary.empty?
    assert_equal 3, primary.size

    Zlib::GzipReader.open(test_data('rpms/repo-1/repodata/primary.xml.gz')) do |_expected_primary|
      buffer = StringIO.new
      primary.write(buffer)
      #      assert_equal(expected_primary.read, buffer.string)
      #     assert_xml_equal(expected_primary, buffer.string)
    end
  end
end
