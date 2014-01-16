require 'spec_helper'
require 'pry'

describe Alephant::Alephant do
  subject { Alephant::Alephant }

  describe "initialize(opts = {})" do
    before(:each) do
      sequencer = double()
      queue     = double()
      cache     = double()
      renderer  = double()

      Alephant::Sequencer.any_instance.stub(:initialize).and_return(sequencer)
      Alephant::Queue.any_instance.stub(:initialize).and_return(queue)
      Alephant::Cache.any_instance.stub(:initialize).and_return(cache)
      Alephant::Renderer.any_instance.stub(:initialize).and_return(renderer)
    end

    it "sets specified options" do
      instance = subject.new({
        :s3_bucket_id       => :s3_bucket_id,
        :s3_object_path     => :s3_object_path,
        :s3_object_id       => :s3_object_id,
        :table_name         => :table_name,
        :sqs_queue_id       => :sqs_queue_id,
        :view_id            => :view_id,
        :sequential_proc    => :sequential_proc,
        :set_last_seen_proc => :set_last_seen_proc
      })

      expect(instance.s3_bucket_id).to eq(:s3_bucket_id);
      expect(instance.s3_object_path).to eq(:s3_object_path);
      expect(instance.s3_object_id).to eq(:s3_object_id);
      expect(instance.table_name).to eq(:table_name);
      expect(instance.sqs_queue_id).to eq(:sqs_queue_id);
      expect(instance.view_id).to eq(:view_id);
      expect(instance.sequential_proc).to eq(:sequential_proc);
      expect(instance.set_last_seen_proc).to eq(:set_last_seen_proc);
    end

    it "sets unspecified options to nil" do
      instance = subject.new

      expect(instance.s3_bucket_id).to eq(nil);
      expect(instance.s3_object_path).to eq(nil);
      expect(instance.s3_object_id).to eq(nil);
      expect(instance.table_name).to eq(nil);
      expect(instance.sqs_queue_id).to eq(nil);
      expect(instance.view_id).to eq(nil);
      expect(instance.sequential_proc).to eq(nil);
      expect(instance.set_last_seen_proc).to eq(nil);
    end

    context "initializes @sequencer" do
      it "with Sequencer.new({ :table_name => :table_name }, @sqs_queue_id)" do
        Alephant::Sequencer.should_receive(:new)
          .with({ :table_name => :table_name }, :sqs_queue_id)

        instance = subject.new({
          :table_name   => :table_name,
          :sqs_queue_id => :sqs_queue_id
        })
      end
    end

    context "initializes @queue" do
      it "with Queue.new(@sqs_queue_id)" do
        Alephant::Queue.should_receive(:new).with(:sqs_queue_id)

        instance = subject.new({
          :sqs_queue_id => :sqs_queue_id
        })
      end
    end

    context "initializes @cache" do
      it "with Cache.new(@s3_bucket_id, @s3_object_path)" do
        Alephant::Cache.should_receive(:new).with(:s3_bucket_id, :s3_object_path)

        instance = subject.new({
          :s3_bucket_id   => :s3_bucket_id,
          :s3_object_path => :s3_object_path
        })
      end
    end

    context "initializes @renderer" do
      it "with Renderer.new(@view_id)" do
        Alephant::Renderer.should_receive(:new).with(:view_id)

        instance = subject.new({
          :view_id => :view_id
        })
      end
    end
  end

  describe "run!" do
    before(:each) do
      sequencer = double()
      queue     = double()
      cache     = double()
      renderer  = double()

      Alephant::Sequencer.any_instance.stub(:initialize).and_return(sequencer)
      Alephant::Queue.any_instance.stub(:initialize).and_return(queue)
      Alephant::Cache.any_instance.stub(:initialize).and_return(cache)
      Alephant::Renderer.any_instance.stub(:initialize).and_return(renderer)
    end

    it "returns a Thread" do
      instance = subject.new({
        :sqs_queue_id => :sqs_queue_id
      })

      expect(instance.run!).to be_a(Thread)
    end

    it "calls @queue.poll" do
      instance = subject.new({
        :sqs_queue_id => :sqs_queue_id
      })

      instance.should_receive(:receive)

      expect_any_instance_of(Alephant::Queue).to receive(:poll).and_yield(:msg)

      t = instance.run!
      t.join
    end
  end
end