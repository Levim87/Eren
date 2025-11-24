            HeaderButton.MouseButton1Click:Connect(function()
                IsExpanded = not IsExpanded
                CreateTween(ColorPicker, {
                    Size = UDim2.new(1, -8, 0, IsExpanded and 110 or 40)
                }, 0.3, Enum.EasingStyle.Back)
                CreateTween(ColorPickerStroke, {
                    Color = IsExpanded and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 60, 80)
                }, 0.2)
            end)

            return {
                Set = function(value)
                    Color = value
                    Preview.BackgroundColor3 = value
                end,
                Get = function()
                    return Color
                end
            }
        end

        return TabAPI
    end

    function WindowAPI:Notify(title, content, duration, icon)
    return MirageUI:Notify(title, content, duration, icon)
    end

    function WindowAPI:Destroy()
        ScreenGui:Destroy()
    end

    return WindowAPI
end

return MirageUI