class ArtNet::Node::StNode < ArtNet::Node
  CODE = 0x00
  def node?; true; end
end
class ArtNet::Node::StController < ArtNet::Node
  CODE = 0x01
  def controller?; true; end
end
class ArtNet::Node::StMedia < ArtNet::Node
  CODE = 0x02
  def media?; true; end
end
class ArtNet::Node::StRoute < ArtNet::Node
  CODE = 0x03
  def route?; true; end
end
class ArtNet::Node::StBackup < ArtNet::Node
  CODE = 0x04
  def backup?; true; end
end
class ArtNet::Node::StConfig < ArtNet::Node
  CODE = 0x05
  def config?; true; end
  def diag?; true; end
end
class ArtNet::Node::StVisual< ArtNet::Node
  CODE = 0x06
  def visual?; true; end
end