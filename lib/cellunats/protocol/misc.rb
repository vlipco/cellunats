class Time
  def to_node_timestamp
    (self.to_f*1000).to_i
  end
end