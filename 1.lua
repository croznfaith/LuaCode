-- ============================================================
--   External Bypass Module v4.4 – BGMI optimized
--   Merges existing strong base + missing deep bypasses
--   New welcome dialog text
-- ============================================================

if _G.UltimateBypassInjected then return end
_G.UltimateBypassInjected = true

-- ==================== WELCOME DIALOG ====================
pcall(function()
    local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"]
    if not Msg then pcall(function() Msg = require("client.slua.logic.common.logic_common_msg_box") end) end
    if Msg and Msg.Show then
        Msg.Show(4,
            "GokuConfig Extra Bypass Layer Active",
            "Please turn on firewall for better security.")
    end
end)

-- ==================== UTILS ====================
local noop = function() return true end
local retFalse = function() return false end
local retZero = function() return 0 end
local retEmpty = function() return {} end

local function safeImport(name)
    if type(import) == "function" then
        local ok, ret = pcall(import, name)
        if ok then return ret end
    end
    return nil
end

-- ==================== EXISTING BYPASSES (unchanged) ====================
pcall(function()
    local stExtraBlueprint = safeImport("STExtraBlueprintFunctionLibrary")
    if stExtraBlueprint and stExtraBlueprint.IsDevelopment then
        stExtraBlueprint.IsDevelopment = noop
    end

    if Client then
        Client.IsDevelopment = noop
        Client.IsShipping = retFalse
    end

    if Server then Server.IsShipping = retFalse end

    local ToolReportUtil = package.loaded["client.slua.logic.report.ToolReportUtil"]
    if ToolReportUtil then
        ToolReportUtil.IsReleaseVersion = retFalse
        ToolReportUtil.IsWhite = retFalse
        ToolReportUtil.GetReportSwitch = retFalse
    end

    -- GameplayCallbacks neutralization
    local callbacks = _G.GameplayCallbacks or _G.GC
    if callbacks then
        local funcsToKill = {
            "SendTssSdkAntiDataToLobby", "SendDSErrorLogToLobby", "SendDSHawkEyePatrolLogToLobby",
            "SendSecTLog", "SendDataMiningTLog", "SendActivityTLog", "SendClientMemUsage",
            "SendClientFPS", "OnClientCrashReport", "OnNetworkLossDetected", "ReportMatchRoomData",
            "ReportPlayersPing", "SendClientStats", "SendServerAvgTickDelta", "ReportHitFlow",
            "OnPlayerActorChannelError", "OnPlayerRPCValidateFailed"
        }
        for _, fn in ipairs(funcsToKill) do
            if callbacks[fn] then callbacks[fn] = noop end
        end

        local originalOnDSChanged = callbacks.OnDSPlayerStateChanged
        if originalOnDSChanged then
            callbacks.OnDSPlayerStateChanged = function(dsSelf, state, reason, ...)
                local r = tostring(reason):lower()
                if r == "cheatdetected" or r == "connectionlost" or r == "connectiontimeout" then return end
                pcall(originalOnDSChanged, dsSelf, state, reason, ...)
            end
        end
    end

    if _G.TApmHelper then _G.TApmHelper.postEvent = noop end

    -- PacketCallbacks suppression
    local PC = _G.PacketCallbacks
    if PC then
        PC.player_report_cheat = noop
        PC.upload_loots_rsp = noop
        PC.watch_player_exit = noop
        PC.player_login_report = noop
        PC.player_logout_report = noop
        PC.server_time_report = noop
    end

    -- ServerDataMgr result key deletion
    local sdm = _G.ServerDataMgr
    if sdm and sdm.DeletablePlayerResultKey then
        sdm.DeletablePlayerResultKey["SuspiciousHitCount"] = true
        sdm.DeletablePlayerResultKey["EspTotalSimTraceCnt"] = true
        sdm.DeletablePlayerResultKey["EspTotalImeFocusCnt"] = true
        sdm.DeletablePlayerResultKey["ClientGravityAnomalyCount"] = true
    end

    -- HiggsBosonComponent surface nukes (keep)
    local higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
    if higgs then
        higgs.ControlMHActive = noop
        higgs.TriggerAvatarCheck = noop
        higgs.StartAvatarCheck = noop
        higgs.GetNetAvatarItemIDs = retEmpty
        higgs.GetCurWeaponSkinID = retZero
        higgs.SendHisarData = noop
        higgs.OnLogin = noop
        higgs.ValidateSecurityData = noop
        higgs.StaticShowSecurityAlertInDev = noop
    end
    if _G.DisableHiggsBoson then _G.DisableHiggsBoson = noop end

    -- ClientGlueHiaSystem
    local hia = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem"]
    if hia then
        hia.CheckHitIntegrity = noop
        hia.InitSession = noop
        hia.OnBattleEnd = noop
    end
    if _G.ClientGlueHiaSystem then _G.ClientGlueHiaSystem.CheckHitIntegrity = noop end

    -- SecurityCommonUtils strategy reset
    local secUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"]
    if secUtils and secUtils.EStrategyTypeInReplay then
        secUtils.EStrategyTypeInReplay.EspTotalSimTraceCnt = 0
        secUtils.EStrategyTypeInReplay.EspTotalImeFocusCnt = 0
        secUtils.EStrategyTypeInReplay.ClientGravityAnomalyCount = 0
        secUtils.EStrategyTypeInReplay.FlyingErrorCnt = 0
    end

    -- BehaviorScore
    local BehaviorScore = package.loaded["GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem"]
    if BehaviorScore then
        BehaviorScore.OnHandleBehaviorScore = noop
        BehaviorScore.AIPerceptionScore = noop
        BehaviorScore.ReportBehavior = noop
        BehaviorScore.CalcFinalScore = retZero
    end

    -- SecurityNotifyPCFeature surface nukes
    local pcNotify = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"]
    if pcNotify then
        pcNotify.ClientRPC_SyncBanID = noop
        pcNotify.ClientRPC_StrongTips = noop
        pcNotify.ClientRPC_NormalTips = noop
        pcNotify.Notify = noop
        pcNotify.ClientRPC_NotifyBan = noop
        pcNotify.ClientRPC_NotifyPunish = noop
        pcNotify.ClientRPC_NotifyIllegalProgram = noop
    end

    -- ClientBanLogic
    local ClientBanLogic = package.loaded["client.slua.logic.ban.ClientBanLogic"]
    if ClientBanLogic then
        ClientBanLogic.OnSyncBanInfo = noop
        ClientBanLogic.OnVoiceBanNotify = noop
        ClientBanLogic.OnRealTimeVoiceBanNotify = noop
        ClientBanLogic.OnVoiceBanSuccess = noop
        ClientBanLogic.OnSyncMicSuspicious = noop
        ClientBanLogic.OnSyncMicPreFilter = noop
        ClientBanLogic.OnNotifyWarningTips = noop
        ClientBanLogic.ReqBanInfo = noop
    end

    -- Ban utilities
    local BanUtil = package.loaded["client.common.ban_util"] or _G.ban_util
    if BanUtil then
        BanUtil.CheckBanStatus = retFalse
        BanUtil.GetBanTime = retZero
        BanUtil.IsBanForever = retFalse
    end

    -- TT Ban
    local TTBan = package.loaded["client.logic.login.logic_tt_ban"] or _G.logic_tt_ban
    if TTBan then
        TTBan.CheckIfCanCreateRole = noop
        TTBan.JumpAppealURL = retFalse
        TTBan.GetCarrierInfo = function() return "[{\"mcc\":\"000\"}]" end
    end

    -- GodzillaBanHandler
    local GodzillaBan = package.loaded["client.network.Protocol.GodzillaBanHandler"] or _G.GodzillaBanHandler
    if GodzillaBan then
        GodzillaBan.send_godzilla_ban_req = noop
        GodzillaBan.send_godzilla_unban_req = noop
    end

    -- Anti‑addiction
    local AntiAddiction = package.loaded["client.network.Protocol.AntiaddctionHandler"] or _G.AntiaddctionHandler
    if AntiAddiction then
        AntiAddiction.send_anti_addiction_req = noop
        AntiAddiction.send_anti_addiction_notify = noop
        AntiAddiction.on_check_nonage_anti_work = noop
    end

    -- AccessRestriction
    local AccessRestrict = package.loaded["client.network.Protocol.AccessRestrictionHandler"] or _G.AccessRestrictionHandler
    if AccessRestrict then
        AccessRestrict.send_access_restriction_req = noop
        AccessRestrict.send_access_restriction_notify = noop
        AccessRestrict.on_player_cheat_state_notify = noop
    end

    -- DeleteAccount
    local DeleteAccount = package.loaded["client.slua.logic.gdpr.logic_deleteaccount"] or _G.logic_deleteaccount
    if DeleteAccount then
        DeleteAccount.ForceDeleteAccount = retFalse
        DeleteAccount.OnReceiveDeleteNotify = noop
    end

    -- Compliance
    local ComplianceUtil = package.loaded["client.slua.logic.gdpr.compliance_util"] or _G.compliance_util
    if ComplianceUtil then ComplianceUtil.CheckCompliance = noop end

    -- ClientReportPlayerSubsystem surface nukes
    local clientReport = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem"]
    if clientReport then
        clientReport.OnInit = noop
        clientReport._OnPlayerKilledOtherPlayer = noop
        clientReport._RecordFatalDamager = noop
        clientReport.SendPacket = noop
        clientReport.ReportSuspiciousPlayer = noop
        clientReport.SubmitReport = noop
        clientReport._OnBattleResult = noop
        clientReport._RecordTeammatePlayerInfo = noop
        clientReport._OnDeathReplayDataWhenFatalDamaged = noop
        clientReport._RecordMurdererFromDeathReplayData = noop
    end

    -- DSReportPlayerSubsystem
    local dsReport = package.loaded["GameLua.Mod.BaseMod.Common.Security.DSReportPlayerSubsystem"]
    if dsReport then
        dsReport._OnNearDeathOrRescued = noop
        dsReport._OnPlayerSettlementStart = noop
        dsReport._OnTeammateDamage = noop
        dsReport._OnCharacterDied = noop
    end

    -- ReportPlayerUtils
    local reportUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils"]
    if reportUtils then
        reportUtils.GetBotType = retZero
        reportUtils.IsCharacterDeliverAI = retFalse
    end

    -- AvatarExceptionSubsystem
    local AvatarSubsystem = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionSubsystem"] or _G.AvatarExceptionSubsystem
    if AvatarSubsystem then
        AvatarSubsystem.OnClickReportCheckAvatar = noop
        AvatarSubsystem.RegisterTickCheckCharacterAvatar = noop
    end
    if _G.AvatarExceptionPlayerInst then
        _G.AvatarExceptionPlayerInst.ReportAvatarException = noop
        _G.AvatarExceptionPlayerInst.CheckAvatarException = noop
        _G.AvatarExceptionPlayerInst.CheckCanBugglyPostException = noop
    end

    -- DSHawkEyePatrolSubsystem
    local SubsystemMgr = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"] or require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
        local patrolSubsystem = SubsystemMgr:Get("DSHawkEyePatrolSubsystem")
        if patrolSubsystem then patrolSubsystem.MarkSuspiciousPlayer = noop end
    end

    local DSHawkEye = _G.DSHawkEyePatrolSubsystem
    if DSHawkEye then
        DSHawkEye._OnHawkReport = noop
        DSHawkEye._OnHawkImprison = noop
        DSHawkEye.CheckPunishPlayer = noop
    end

    -- ClientHawkEyePatrolSubsystem surface nukes
    local ClientHawkEye = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
    if ClientHawkEye then
        ClientHawkEye._OnHawkSync = noop
        ClientHawkEye._OnHawkReportSuccess = noop
        ClientHawkEye._StartExitGameTimer = noop
        ClientHawkEye._OnRecvInspectorBroadcastCount = noop
        ClientHawkEye.CanInspectorBroadcast = retFalse
        ClientHawkEye.SendReportTLog = noop
        ClientHawkEye.ReportCheat = noop
    end

    -- InspectionSystem clientside
    local InspectClient = package.loaded["GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem"]
    if InspectClient then
        InspectClient.AskForInspector = noop
        InspectClient.ReportEnemy = noop
        InspectClient.KickOutOneTeam = noop
        InspectClient.OnReceiveInspectCmd = noop
        InspectClient.ClientReportData = noop
        InspectClient.SendReportToInspector = noop
        InspectClient.SendKickOutOneTeam = noop
        InspectClient.ClientNotifyInspectorImplementation = noop
        InspectClient.RecvNotifyInspector = noop
    end

    -- InspectionSystem DS
    local InspectDS = package.loaded["GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem"]
    if InspectDS then
        InspectDS.ServerKickOutOneTeamByPlayerImplementation = noop
        InspectDS.AddReportedCount = noop
        InspectDS.AddInspectionRecord = noop
        InspectDS.BanPlayerByInspection = noop
        InspectDS.BroadCastToAllInspector = noop
        InspectDS.ServerReportToInspectorImplementation = noop
        InspectDS.InitPlayerInspectionInfo = noop
    end

    -- TLog handlers
    local ClientTlog = package.loaded["client.network.Protocol.ClientTlogHandler"] or _G.ClientTlogHandler
    if ClientTlog then ClientTlog.send_report_lobby_common_tlog = noop end

    local LoginWinTlog = package.loaded["client.network.Protocol.LoginAndWinTlogHandler"] or _G.LoginAndWinTlogHandler
    if LoginWinTlog then LoginWinTlog.on_cloud_game_event_notify = noop end

    local TLogUtils = package.loaded["client.slua.config.tlog.tlog_report_utils"] or _G.tlog_report_utils
    if TLogUtils then
        TLogUtils.ReportTLogEvent = noop
        TLogUtils.ReportImmediate = noop
    end

    local BasicTLog = package.loaded["client.slua.data.BasicData.BasicDataTLogReport"] or _G.BasicDataTLogReport
    if BasicTLog then
        BasicTLog.OnSendBatchReqMsg = noop
        BasicTLog.OnImmediateReqMsg = noop
        BasicTLog.OnMergeReqMsg = noop
        BasicTLog.send_report_event_duration_log = noop
        BasicTLog.SendTlog = noop
        BasicTLog.ReportEvent = noop
        BasicTLog._GetParamData = retEmpty
    end

    local BasicClientReport = package.loaded["client.slua.data.BasicData.BasicDataClientReport"] or _G.BasicDataClientReport
    if BasicClientReport then
        BasicClientReport.ReportImmediate = noop
        BasicClientReport.ReportDelay = noop
        BasicClientReport.OnSendBatchReqMsg = noop
        BasicClientReport.OnImmediateReqMsg = noop
        BasicClientReport.OnMergeReqMsg = noop
        BasicClientReport._IsCanReport = retFalse
    end

    local BasicReport = package.loaded["client.slua.data.BasicData.BasicDataReport"] or _G.BasicDataReport
    if BasicReport then
        BasicReport.ReportImmediate = noop
        BasicReport.ReportDelay = noop
        BasicReport.OnMergeReqMsg = noop
        BasicReport.OnImmediateReqMsg = noop
        BasicReport.OnSendBatchReqMsg = noop
        BasicReport._BatchReqMsg = noop
    end

    -- Vehicle TLog
    local AmphibiousBoat = package.loaded["GameLua.GameCore.Module.Vehicle.VehicleFeatures.TLog.AmphibiousBoatTLogFeature"]
    if AmphibiousBoat then
        AmphibiousBoat.RecordMovement = noop
        AmphibiousBoat.StartRecordMovement = noop
    end

    -- Puffer TLog
    local PufferTlog = package.loaded["client.slua.logic.download.report.puffer_tlog"] or _G.puffer_tlog
    if PufferTlog then PufferTlog.report_download_tlog = noop end

    -- ICTLog
    local ICTLog = package.loaded["GameLua.Mod.BaseMod.DS.Security.ICTLogSubsystem"]
    if ICTLog then ICTLog.SendICExceptionTLog = noop end

    -- DSFightTLog
    local DSFightTLog = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem"]
    if DSFightTLog then
        DSFightTLog.GetSimpleFightData = retEmpty
        DSFightTLog.ReportFightData = noop
        DSFightTLog.ReportPlayerWeapon = noop
    end

    -- DSSecurityTLog
    local DSSecurity = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem"]
    if DSSecurity then
        DSSecurity._OnReportServerJumpFlow = noop
        DSSecurity._OnReportTeleportFlow = noop
        DSSecurity._OnReportSpeedHackFlow = noop
    end

    -- DSCommonTLog
    local DSCommon = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem"]
    if DSCommon then DSCommon.HandleKillTlog = noop end

    -- DSReportPlayer extra
    local DSReportPlayer = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"]
    if DSReportPlayer then
        DSReportPlayer._AddEnemyMapToBattleResult = noop
        DSReportPlayer._AddTeammateMapToBattleResult = noop
        DSReportPlayer._SubmitAbnormalData = noop
    end

    -- Error/Crash report handlers
    local ClientError = package.loaded["client.network.Protocol.ClientErrorReportHandler"] or _G.ClientErrorReportHandler
    if ClientError then
        ClientError.send_client_error_report = noop
        ClientError.send_client_crash_report = noop
        ClientError.send_client_tools_batch_report_req = noop
    end

    local BattleReport = package.loaded["client.network.Protocol.BattleReportHandler"] or _G.BattleReportHandler
    if BattleReport then
        BattleReport.send_battle_report = noop
        BattleReport.send_battle_result = noop
        BattleReport.send_vod_game_report_req = noop
        BattleReport.send_batch_get_vod_info_req = noop
        BattleReport.send_get_game_report_req = noop
        BattleReport.send_batch_get_game_report_req = noop
        BattleReport.send_get_game_report_by_uid_req = noop
    end

    local BugHandler = package.loaded["client.network.Protocol.BugHandler"] or _G.BugHandler
    if BugHandler then
        BugHandler.send_report_bug_info = noop
        BugHandler.send_report_bug_feedback = noop
    end

    -- Ping / week reports
    local PingReport = package.loaded["client.network.Protocol.LobbyPingReportHandler"] or _G.LobbyPingReportHandler
    if PingReport then
        PingReport.send_lobby_ping_report = noop
        PingReport.send_ingame_ping_report = noop
    end

    local WeekReport = package.loaded["client.network.Protocol.WeekRportHandler"] or _G.WeekRportHandler
    if WeekReport then
        WeekReport.send_week_report = noop
        WeekReport.send_week_detail = noop
    end

    -- Complaint logic
    local LogicComplaint = package.loaded["client.logic.battle.logic_complaint"] or _G.logic_complaint
    if LogicComplaint then
        LogicComplaint.SendComplaintReq = noop
        LogicComplaint.Submit = noop
        LogicComplaint.ReportPlayer = noop
        LogicComplaint.ShowComplaint = noop
        LogicComplaint.ShowHandle = noop
    end

    -- Battle result handlers
    local OBResult = package.loaded["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.EscapeBattleResultShowOBResultLogic"]
    if OBResult then
        OBResult.OnBattleResult = noop
        OBResult.OnResultProcessStart = noop
    end

    local NormalOBResult = package.loaded["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowOBResultLogic"]
    if NormalOBResult then
        NormalOBResult.OnBattleResult = noop
        NormalOBResult.OnResultProcessStart = noop
    end

    local ShowResult = package.loaded["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowResultLogic"]
    if ShowResult then
        ShowResult.OnBattleResult = noop
        ShowResult.OnResultProcessStart = noop
        ShowResult.OnResultProcessContinue = noop
        ShowResult.ReceiveData = noop
        ShowResult.SendEndFlow = noop
        ShowResult.OnReport = noop
        ShowResult.ShowResult = noop
        ShowResult.ShowResultInternal = noop
        ShowResult.StopResultProcess = noop
    end

    -- Emulator bypass
    local EmuHandler = package.loaded["client.network.Protocol.EmulatorHandler"] or _G.EmulatorHandler
    if EmuHandler then EmuHandler.send_emulator_info = noop end

    local EmuScanner = package.loaded["client.logic.login.emulator_scanner"] or _G.emulator_scanner
    if EmuScanner then
        EmuScanner.StartScan = noop
        EmuScanner.GetScanResult = retFalse
        EmuScanner.ReportScanResult = noop
    end

    -- Login/device verify
    local LoginVerify = package.loaded["client.network.Protocol.LoginVerifyHandler"] or _G.LoginVerifyHandler
    if LoginVerify then
        LoginVerify.send_login_verify_req = noop
        LoginVerify.send_device_verify_req = noop
    end

    -- DS monitor
    local DSMonitor = package.loaded["client.logic.data.logic_ds_monitor"] or _G.logic_ds_monitor
    if DSMonitor then
        DSMonitor.OnRecordMsg = noop
        DSMonitor.OnReportMsg = noop
    end

    -- ClientDataStatistcs
    local ClientDataStat = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientDataStatistcsSubsystem"]
    if ClientDataStat then
        ClientDataStat.StartToCheck = noop
        ClientDataStat.OnReceiveRTT = noop
        ClientDataStat.OnReceiveJitter = noop
        ClientDataStat.ReportAbnormal = noop
        ClientDataStat.ResetData = noop
    end

    -- Shoot verify
    local shootVerify = package.loaded["GameLua.Dev.Subsystem.ShootVerifySubSystemClient"]
    if shootVerify then
        shootVerify.OnShootVerifyFailed = noop
        shootVerify.SendVerifyData = noop
    end

    -- HighlightMoment DS checker
    local HighlightDS = package.loaded["GameLua.Mod.BaseMod.DS.Security.HighlightMomentSubsystem_DSChecker"]
    if HighlightDS then HighlightDS.CheckFuncUpgradedWeaponKill = noop end

    -- Profile report
    local ProfileReport = package.loaded["client.logic.data.profile_report_cfg"] or _G.profile_report_cfg
    if ProfileReport then ProfileReport.SendReport = noop end

    -- Voice report / doctor
    local VoiceReport = package.loaded["client.slua.logic.chat_voice.logic_chat_voice_report"] or _G.logic_chat_voice_report
    if VoiceReport then
        VoiceReport.ReportVoiceData = noop
        VoiceReport.ReportVoiceText = noop
    end

    local VoiceDoctor = package.loaded["client.slua.logic.chat_voice.logic_chat_voice_doctor"] or _G.logic_chat_voice_doctor
    if VoiceDoctor then
        VoiceDoctor.UploadVoiceLog = noop
        VoiceDoctor.UploadVoiceException = noop
    end

    -- Home audit / report
    local HomeAudit = package.loaded["client.slua.logic.home.Audit.logic_home_audit_state"] or _G.logic_home_audit_state
    if HomeAudit then
        HomeAudit.SendAuditState = noop
        HomeAudit.ReportAuditResult = noop
    end

    local HomeReport = package.loaded["client.slua.logic.home.logic_home_report"] or _G.logic_home_report
    if HomeReport then
        HomeReport.ReportHomeData = noop
        HomeReport.ReportHomeVisitor = noop
    end

    -- Gem report
    local GemReport = package.loaded["client.logic.store.gem_report_utils"] or _G.gem_report_utils
    if GemReport then
        GemReport.ReportGemData = noop
        GemReport.ReportGemPurchase = noop
    end

    -- SafeStation / CustomerService
    local SafeStation = package.loaded["client.slua.logic.CustomerService.LogicSafeStation"] or _G.LogicSafeStation
    if SafeStation then
        SafeStation.UploadVideoEvidence = noop
        SafeStation.ReportPlayerBehavior = noop
    end

    local CustomerService = package.loaded["client.slua.logic.CustomerService.LogicCustomerService"] or _G.LogicCustomerService
    if CustomerService then
        CustomerService.SendComplaint = noop
        CustomerService.SendFeedback = noop
    end

    -- ZNQ revival subsystems
    local znq6Revive = package.loaded["GameLua.Mod.TDEvent.ZNQ6th.DS.ZNQ6thDSReviveSubsystem"]
    if znq6Revive then znq6Revive.HaveNewItemForRevive = noop end

    local znq7Revive = package.loaded["GameLua.Mod.TDEvent.ZNQ7th.DS.ZNQ7DSReviveSubsystem"]
    if znq7Revive then znq7Revive.HaveChanceRevival = noop end

    -- Spectator watcher override
    local DataLayer = package.loaded["GameLua.Mod.BaseMod.Common.Subsystem.DataLayerSubsystem"]
    if DataLayer then
        local origOnSpectator = DataLayer.OnSpectatorReplayChanged
        if origOnSpectator then
            DataLayer.OnSpectatorReplayChanged = function(dlSelf)
                _G.IsBeingWatched = true
                origOnSpectator(dlSelf)
            end
        end
    end

    -- DSActive kick prevention
    local DSActive = package.loaded["GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem"]
    if DSActive then
        DSActive.DelayKickOutPlayer = noop
        DSActive.ActiveKickNotify = noop
    end

    -- Creative mode debug
    local CreativeDevDebug = package.loaded["GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeDevDebugSubsystem"]
    if CreativeDevDebug then CreativeDevDebug.IsDebugPanelEnalbedCli = noop end

    -- Creative death record
    local CreativeDeath = package.loaded["GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeModeDeathRecordSubsystem"]
    if CreativeDeath then CreativeDeath.OnPlayerKilled = noop end

    -- Replay data reporter
    if _G.ClientReplayDataReporter then
        _G.ClientReplayDataReporter.ReportIntArrayData = noop
        _G.ClientReplayDataReporter.ReportFloatArrayData = noop
    end

    -- Spectate / replay
    local SpectateReplay = package.loaded["GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem"]
    if SpectateReplay then
        SpectateReplay.RequestGotoSpectatingImp = noop
        SpectateReplay.RequestGotoSpectating = noop
    end

    -- AI Replay
    local AIReplay = package.loaded["GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem"]
    if AIReplay then
        AIReplay.ReportAllPlayerInfo = noop
        AIReplay.ReportFrameData = noop
        AIReplay.ReportPlayerInput = noop
        if AIReplay.uCompletePlayBack then
            AIReplay.uCompletePlayBack.AddRecordMLAIInfo = noop
            AIReplay.uCompletePlayBack.StopRecording = noop
        end
    end

    -- AI Tracking
    local AITracking = package.loaded["GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem"]
    if AITracking then
        AITracking.RealLogoutTimer = noop
        AITracking.LogQueue = {}
        AITracking.AddToLogQue = noop
        AITracking.DoPrint = noop
        AITracking.OnAIPawnDied = noop
        AITracking.OnAIPawnReceiveDamage = noop
        AITracking.OnAIPawnEnemyChange = noop
    end

    -- AFK report
    local AFKReport = package.loaded["GameLua.Mod.BaseMod.DS.Security.AFKReportorSubsystem"]
    if AFKReport then
        AFKReport.HandleEnterFighting = noop
        AFKReport.InitializePlayerInputInfo = noop
        AFKReport.AddOneAFKInfo = noop
        AFKReport.SetPlayerAFKState = noop
        AFKReport.ResetPlayerInputInfo = noop
        AFKReport.PlayerHaveAction = noop
    end

    -- TDM AFK
    local TDMAFK = package.loaded["GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem"]
    if TDMAFK then
        TDMAFK.SendAFKTips = noop
        TDMAFK.OnHandleLostConnection = noop
    end

    -- DataMgr weapon volume
    local DataMgr = package.loaded["client.slua.logic.data.data_mgr"] or _G.DataMgr
    if DataMgr then DataMgr.GetWeaponSkinSoundVolumeInfoByGroup = retZero end

    -- Credit logic
    local CreditLogic = package.loaded["GameLua.Mod.BaseMod.Client.ClientInGameCreditLogic"] or _G.ClientInGameCreditLogic
    if CreditLogic then
        CreditLogic._SendUserReaction2ExitTeamBeforeBoardingReturnLobbyNotice = noop
        CreditLogic.ShowReturnLobbyIfFirstExitTeamBeforeBoarding = retFalse
        CreditLogic.OnReceiveCreditScoreChange = noop
        CreditLogic._IsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled = retFalse
        CreditLogic.SetFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled = noop
    end

    -- Global function overrides
    local globalFunctionsToKill = {
        "ReportTLogEvent", "SendTlog", "SendClientStats", "ReportHitFlow",
        "ReportAvatarException", "SendComplaintReq", "SubmitReport",
        "ReportSuspiciousPlayer", "SendPacket", "OnSyncBanInfo",
        "OnVoiceBanNotify", "SendSecTLog", "MarkSuspiciousPlayer",
        "ReportPlayerBehaviorData", "CheckCompliance", "ReportIllegalProgram", "UploadVoiceLog"
    }
    for _, fnName in ipairs(globalFunctionsToKill) do
        if type(_G[fnName]) == "function" then
            _G[fnName] = noop
        end
    end

    -- Additional ClientBanLogic handling
    local cbl = package.loaded["client.network.Protocol.ClientBanLogic"] or _G.ClientBanLogic
    if cbl then
        cbl.ReqBanInfo = noop
        cbl.IsVoiceReportEnable = retFalse
        cbl.OnVoiceSwitchNotify = noop
        cbl.OnSyncMicPreFilter = noop
    end

    -- Chat report
    local chatHandler = package.loaded["client.network.Protocol.ChatHandler"] or _G.ChatHandler
    if chatHandler then
        chatHandler.send_report_info = noop
        chatHandler.send_report_info_mic = noop
    end

    -- Timer cleanup (use with caution)
    if _G.KillAllTimers then _G.KillAllTimers() end
end)

-- ==================== NEW: MISSING DEEP BYPASSES (from second code) ====================
-- These are only added if not already present in the base above.

pcall(function()
    -- 1. UnrealNet exception filter (prevents CheatDetected / IdipBan kicks)
    if UnrealNet then
        local orig_Filter = UnrealNet.FilterNetworkException
        if orig_Filter then
            UnrealNet.FilterNetworkException = function(ExceptionType, ErrorMessage)
                if ErrorMessage then
                    if string.find(ErrorMessage, "CheatDetected") or
                       string.find(ErrorMessage, "IdipBan") then
                        return false
                    end
                end
                return orig_Filter(ExceptionType, ErrorMessage)
            end
        end
        UnrealNet.HandleNetworkExceptionReport  = noop
        UnrealNet.HandleNetworkConnectionClosed = noop
        UnrealNet.HandleSpectateException       = noop
    end

    -- 2. Gokuba root/malware detection bypass
    local Gokuba = package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"] or
                   (pcall(require, "GameLua.Mod.BaseMod.Client.Security.Gokuba") and
                    package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"])
    if Gokuba then
        Gokuba.ForwardFeature = function()
            local tbResult = {[1]=0, [2]=0, [3]=0, [4]=0, [5]=0}
            pcall(NetUtil.SendPkg, "battle_client_sync_allstar_auth_check_result_req", tbResult)
        end
    end

    -- 3. GameSafeCallbacks neutralization
    if _G.GameSafeCallbacks then
        local GS = _G.GameSafeCallbacks
        GS.PostPlayerControllerLoginInit      = noop
        GS.OnDSGlueHiaInit                   = noop
        GS.CharacterReceiveBeginPlay          = noop
        GS.DoAttackFlowStrategy              = noop
        GS.GetScriptReportContent            = function() return "" end
        GS.RecordStrategyTimestampInReplay   = noop
        GS.EditorIncreaseTotalStatisticCnt   = noop
    end

    -- 4. GameReportUtils (Bugly) crash upload suppression
    local GRU = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
    if not GRU then pcall(function() GRU = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils") end) end
    if GRU then
        GRU.BugglyPostExceptionFull       = function() return false end
        GRU.ReportException               = noop
        GRU.CheckCanBugglyPostException   = function() return false end
    end

    -- 5. ClientToolsReport and ReportPlatformCrashKit
    local CTR = package.loaded["client.slua.logic.report.ClientToolsReport"]
    if not CTR then pcall(function() CTR = require("client.slua.logic.report.ClientToolsReport") end) end
    if CTR then CTR.SendReport = noop end

    local RPCK = package.loaded["client.slua.logic.report.ReportPlatformCrashKit"]
    if not RPCK then pcall(function() RPCK = require("client.slua.logic.report.ReportPlatformCrashKit") end) end
    if RPCK then
        RPCK.Send      = noop
        RPCK.ForceSend = noop
    end

    -- 6. NetUtil.SendPkg packet filter (blocks 35+ report packets)
    if NetUtil and NetUtil.SendPkg and not NetUtil._ExternalFiltered then
        local orig_SendPkg = NetUtil.SendPkg
        local BlockedPackets = {
            ["on_crow_update_ntf"]   = true,
            ["on_crow_update_ntf2"]  = true,
            ["on_crow_update_ntf3"]  = true,
            ["hisar"]                = true,
            ["battle_client_sync_allstar_auth_check_result_req"] = true,
            ["report_unrealnet_event"]     = true,
            ["report_unrealnet_exception"] = true,
            ["ReportAttackFlow"]     = true,
            ["ReportSecAttackFlow"]  = true,
            ["ReportHurtFlow"]       = true,
            ["ReportFireArms"]       = true,
            ["ReportVerifyInfoFlow"] = true,
            ["ReportMrpcsFlow"]      = true,
            ["ReportPlayerBehavior"] = true,
            ["ReportTeammatHurt"]    = true,
            ["ReportPlayerMoveRoute"]    = true,
            ["ReportPlayerPosition"]     = true,
            ["ReportVehicleMoveFlow"]    = true,
            ["ReportSecTgameMovingFlow"] = true,
            ["report_parachute_data"]    = true,
            ["report_players_ping"]              = true,
            ["report_player_ip"]                 = true,
            ["report_player_frame_ping_record"]  = true,
            ["report_net_saturate"]              = true,
            ["report_ds_netsaturate"]            = true,
            ["report_ds_net_continuous_saturate"]= true,
            ["report_ds_netrate"]                = true,
            ["report_unrealnet_clientstats"]     = true,
            ["report_serverstat_avgtickdelta"]   = true,
            ["ReportAimFlow"]        = true,
            ["ReportHitFlow"]        = true,
            ["ReportJumpFlow"]       = true,
            ["ReportCircleFlow"]     = true,
            ["ReportEquipmentFlow"]  = true,
            ["report_common_info"]   = true,
            ["report_common_battle_info"] = true,
            ["on_tss_sdk_anti_data"] = true,
        }
        NetUtil.SendPkg = function(msgName, ...)
            if BlockedPackets[msgName] then return end
            return orig_SendPkg(msgName, ...)
        end
        NetUtil._ExternalFiltered = true
    end

    -- 7. NetUtil.SendTss direct block
    if NetUtil then
        NetUtil.SendTss = noop
    end

    -- 8. GlobalPlayerCoronaData metatable write protection
    _G.GlobalPlayerCoronaData = _G.GlobalPlayerCoronaData or {}
    local mtCorona = getmetatable(_G.GlobalPlayerCoronaData) or {}
    mtCorona.__newindex = function() end
    setmetatable(_G.GlobalPlayerCoronaData, mtCorona)

    _G.GlobalPlayerCheatTimes = _G.GlobalPlayerCheatTimes or {}
    local mtCheatTimes = getmetatable(_G.GlobalPlayerCheatTimes) or {}
    mtCheatTimes.__newindex = function() end
    setmetatable(_G.GlobalPlayerCheatTimes, mtCheatTimes)

    -- 9. AvatarExceptionReport inner‑impl hooks (more resilient)
    local AvatarExReport = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.AvatarExceptionReport"]
    if not AvatarExReport then pcall(function() AvatarExReport = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarExceptionReport") end) end
    if AvatarExReport and AvatarExReport.__inner_impl then
        AvatarExReport.__inner_impl.OnRecordAvatarException = noop
        AvatarExReport.__inner_impl.OnPreBattleResult       = noop
        AvatarExReport.__inner_impl.OnAvatarAlarm           = noop
    end

    -- 10. HiggsBosonComponent inner‑impl
    local HB = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
    if HB and HB.__inner_impl then
        HB.__inner_impl.SendAntiDataFlow   = noop
        HB.__inner_impl.SendHitFireBtnFlow = noop
        HB.__inner_impl.OnBattleResult     = noop
        HB.__inner_impl.SendHisarData      = noop
    end

    -- 11. ClientHawkEyePatrolSubsystem inner‑impl
    local HawkEye = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
    if HawkEye and HawkEye.__inner_impl then
        HawkEye.__inner_impl._OnHawkSync          = noop
        HawkEye.__inner_impl._OnHawkReportSuccess = noop
        HawkEye.__inner_impl.TryShowReportedTips  = noop
    end

    -- 12. ClientReportPlayerSubsystem inner‑impl
    local CRP = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem"]
    if CRP and CRP.__inner_impl then
        CRP.__inner_impl._OnSyncFatalDamage        = noop
        CRP.__inner_impl._OnPlayerKilledOtherPlayer = noop
        CRP.__inner_impl._SyncBattleResult         = noop
    end

    -- 13. SecurityNotifyPCFeature inner‑impl SyncBanInfo
    local SNF = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"]
    if SNF and SNF.__inner_impl then
        SNF.__inner_impl.SyncBanInfo = noop
    end
end)

-- Done – all bypasses active