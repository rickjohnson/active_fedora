require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# Some tentative extensions to ActiveFedora::Base

describe ActiveFedora::Base do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @base = ActiveFedora::Base.new
    @base.stubs(:create_date).returns("2008-07-02T05:09:42.015Z")
    @base.stubs(:modified_date).returns("2008-09-29T21:21:52.892Z")
  end
  
  describe ".file_objects" do
    it "should be a supported method" do
      @base.should respond_to("file_objects")
    end
    it "should wrap .collection_members and .parts" do
      @base.expects(:collection_members).returns([])
      @base.expects(:parts).returns(["Foo"])
      @base.file_objects
    end
    describe "_remove" do
      it "should wrap collection_members_remove"
    end
  end
  
  describe ".file_objects_append" do
    it "should make the file object being appended assert isPartOf pointing back at the current object and save the child" do
      mock_child = ActiveFedora::Base.new
      mock_child.expects(:add_relationship).with(:is_part_of, @base)
      mock_child.expects(:save)
      @base.file_objects_append(mock_child)
    end
    it "should load the file object being appended if only a pid is provided and save the child" do
      mock_child = mock("object")
      mock_child.expects(:add_relationship).with(:is_part_of, @base)
      mock_child.expects(:save)
      ActiveFedora::Base.expects(:load_instance).with("_PID_").returns(mock_child)
      @base.file_objects_append("_PID_")
    end
  end
  
  describe ".parts" do
    it "should search for both (outbound) has_part and (inbound) is_part_of relationships, removing duplicates" do
      @base.expects(:parts_outbound).returns(["A", "B"])
      @base.expects(:parts_inbound).returns(["B", "C"])
      @base.parts.should == ["B", "C", "A"]
    end
  end
  
  describe ".collection_members" do
    it "should return an array" do
      @base.collection_members.should be_kind_of(Array)
    end
    it "should search for all of the :collection_members" 
    describe "_append" do
      it "should be a supported method" do
        @base.should respond_to(:collection_members_append)
      end
      it "should assert hasCollectionMember for the given object/pid" do
        mocko = mock("object")
        @base.expects(:add_relationship).with(:has_collection_member, mocko)
        @base.collection_members_append(mocko)
      end
      it "should support << operator" do
        pending
        # I can't remember how to do this, and it's not a deal breaker... (MZ)
        mocko = mock("object")
        @base.expects(:add_relationship).with(:has_collection_member, mocko)
        @base.collection_members << mocko
      end
    end
    describe "_remove" do
      it "should be a supported method" do
        @base.should respond_to(:collection_members_remove)
      end
      it "should remove hasCollectionMember for the given object/pid"
    end
  end
  
  describe ".add_file_datastream" do
    it "should create a new datastream with the file as its content" do
      mock_file = mock("File")
      mock_ds = mock("Datastream")
      ActiveFedora::Datastream.expects(:new).with(:dsLabel => "", :controlGroup => 'M', :blob=>mock_file).returns(mock_ds)
      @base.expects(:add_datastream).with(mock_ds)
      @base.add_file_datastream(mock_file)
    end
    it "should apply filename argument to the datastream label if it is provided" do
      mock_file = mock("File")
      mock_ds = mock("Datastream")
      ActiveFedora::Datastream.expects(:new).with(:dsLabel => "My Label", :controlGroup => 'M', :blob=>mock_file).returns(mock_ds)
      @base.expects(:add_datastream).with(mock_ds)
      @base.add_file_datastream(mock_file, :label => "My Label")
    end
    it "should use :dsid if provided" do
      mock_file = mock("File")
      mock_ds = mock("Datastream")
      mock_ds.expects(:dsid=).with("__DSID__")
      ActiveFedora::Datastream.expects(:new).with(:dsLabel => "My Label", :controlGroup => 'M', :blob=>mock_file).returns(mock_ds)
      @base.expects(:add_datastream).with(mock_ds)
      @base.add_file_datastream(mock_file, :label => "My Label", :dsid => "__DSID__")
    end
    
  end
end