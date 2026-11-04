local T={bg=Color3.fromRGB(14,20,24),panel=Color3.fromRGB(25,34,39),edge=Color3.fromRGB(73,88,88),gold=Color3.fromRGB(222,188,121),text=Color3.fromRGB(235,234,219),muted=Color3.fromRGB(156,174,172),green=Color3.fromRGB(92,169,133),red=Color3.fromRGB(180,78,76)}
function T.frame(parent,name,pos,size,color)
 local f=Instance.new("Frame");f.Name=name;f.Position=pos;f.Size=size;f.BackgroundColor3=color or T.panel;f.BorderSizePixel=0;f.Parent=parent
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=f
 return f
end
function T.label(parent,name,words,pos,size,fontSize,color)
 local t=Instance.new("TextLabel");t.Name=name;t.Text=words;t.Position=pos;t.Size=size;t.BackgroundTransparency=1
 t.TextColor3=color or T.text;t.Font=Enum.Font.Gotham;t.TextSize=fontSize or 16;t.TextWrapped=true;t.Parent=parent
 return t
end
function T.button(parent,name,words,pos,size,callback,color)
 local b=Instance.new("TextButton");b.Name=name;b.Text=words;b.Position=pos;b.Size=size;b.BackgroundColor3=color or T.edge
 b.TextColor3=T.text;b.Font=Enum.Font.GothamMedium;b.TextSize=14;b.TextWrapped=true;b.BorderSizePixel=0;b.Parent=parent
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,6);c.Parent=b
 b.Activated:Connect(callback)
 return b
end
function T.scroll(parent,name,pos,size)
 local f=Instance.new("ScrollingFrame");f.Name=name;f.Position=pos;f.Size=size;f.BackgroundTransparency=1;f.BorderSizePixel=0
 f.ScrollBarThickness=5;f.ScrollBarImageColor3=T.gold;f.AutomaticCanvasSize=Enum.AutomaticSize.Y;f.CanvasSize=UDim2.new();f.Parent=parent
 local l=Instance.new("UIListLayout");l.Padding=UDim.new(0,8);l.SortOrder=Enum.SortOrder.LayoutOrder;l.Parent=f
 return f
end
function T.clear(parent)
 for _,child in ipairs(parent:GetChildren()) do if not child:IsA("UIListLayout") and not child:IsA("UICorner") then child:Destroy() end end
end
return T
