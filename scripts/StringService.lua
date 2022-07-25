function str(string)
    return common.IsWString(string) and userMods.FromWString(string) or tostring(string)
end