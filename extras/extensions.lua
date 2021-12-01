function override(class, functionName, extension)
    local original = class[functionName]
    class[functionName] = function(self, ...)
        extension(self, original, ...)
    end
end