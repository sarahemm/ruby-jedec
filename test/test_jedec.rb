#!/usr/bin/ruby

require 'rubygems'
require 'test/unit'
require 'lib/jedec'

class TestJedec < Test::Unit::TestCase
  def test_load
    assert_nothing_raised do
      jedec = Jedec.new('test/data/basic.jed')
    end
  end
  
  def test_syntax_error
    assert_raise SyntaxError do
      jedec = Jedec.new('test/data/syntax_error.jed')
    end
  end
  
  def test_main_fields
    assert_nothing_raised do
      jedec = Jedec.new('test/data/basic.jed')
      assert_equal(100, jedec.nbr_pins)
      assert_equal(32, jedec.nbr_fuses)
      assert_equal(32, jedec.fuse_data.length)
    end
  end
  
  def test_fuse_checksum_error
    assert_raise Jedec::FuseChecksumError do
      jedec = Jedec.new('test/data/checksum_error.jed')
    end
  end
  
  def test_fuse_default_zero
    assert_nothing_raised do
      jedec = Jedec.new('test/data/default_zero.jed')
    end
  end
  
  def test_fuse_default_one
    assert_nothing_raised do
      jedec = Jedec.new('test/data/default_one.jed')
    end
  end
  
  def test_change_fuse_default_after_load
    assert_raise Jedec::FuseDataAlreadyInitialized do
      jedec = Jedec.new('test/data/basic.jed')
      jedec.fuse_data.set_fuse_default(0, jedec.fuse_data.length)
    end
  end
end