state("Frogun", "1.92") 
{
    float speedrunTimer : "GameAssembly.dll", 0x16E5280, 0xB8, 0x0;
    bool isSpeedrunMode : "GameAssembly.dll", 0x16E5A48, 0xB8, 0x2C;
    bool isFadingOut : "GameAssembly.dll", 0x16E5790, 0xB8, 0x0;
    long levelProgress1 : "GameAssembly.dll", 0x16E5A48, 0xB8, 0x8, 0x10, 0x20;
    long levelProgressArray : "GameAssembly.dll", 0x16E5A48, 0xB8, 0x8, 0x10;
}

startup
{
    settings.Add("metadata", true, "Frogun Autosplitter v0.1");
    settings.SetToolTip("metadata", "This isn't an actual setting. It's just here to show which version you're using.");

    vars.emblems = null;
    vars.shouldStartTimer = false;
}

init
{
    if (modules.First().ModuleMemorySize == 0xA3000)
    {
        version = "1.92";
    }
    else
    {
        version = "Unsupported Frogun version";
    }
}

update
{
    if (current.levelProgress1 != 0x0 && old.levelProgress1 == 0x0) 
    {
        vars.emblems = new MemoryWatcherList();
        for (int i = 0; i < 42; i++)
        {
            var levelProgressPointer = new IntPtr(current.levelProgressArray + 0x20 + 0x8 * i);
            var deepPointerEmblemFlag = new DeepPointer(levelProgressPointer, 0x20);
            vars.emblems.Add(new MemoryWatcher<bool>(deepPointerEmblemFlag) { Name = "Emblem " + i });
        }
    }

    if (vars.emblems != null)
    {
        vars.emblems.UpdateAll(game);
    } 
}

gameTime
{
    return TimeSpan.FromSeconds(current.speedrunTimer);
}

isLoading
{
    return true;
}

start
{
    if (current.isSpeedrunMode && !old.isSpeedrunMode)
    {
        vars.shouldStartTimer = true;
    }

    if (vars.shouldStartTimer && old.isFadingOut && !current.isFadingOut)
    {
        vars.shouldStartTimer = false;
        return true;
    }

    return false;
}

reset
{
    return !current.isSpeedrunMode && old.isSpeedrunMode;
}

split
{
    if (vars.emblems != null)
    {
        foreach (var emblem in vars.emblems)
        {
            if (emblem.Current && !emblem.Old)
            {
                return true;
            }
        }
        return false;
    }

    return false;
}