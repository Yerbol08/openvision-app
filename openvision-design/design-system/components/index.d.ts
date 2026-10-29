import type * as React from 'react';
type Status = 'pending' | 'connecting' | 'online' | 'offline' | 'error' | 'disabled';
type Reason = 'waiting_for_video' | 'edge_agent_offline' | 'no_video' | 'waiting_for_gpu' | 'source_unreachable' | 'source_auth_failed' | 'source_not_found' | 'unsupported_codec' | 'no_video_track' | 'private_address_refused' | 'ingest_error' | string;
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> { variant?: 'primary' | 'secondary' | 'ghost' | 'danger'; size?: 'md' | 'sm'; block?: boolean; loading?: boolean; icon?: string }
export declare function Button(props: ButtonProps): React.ReactElement;
export interface TextFieldProps { label?: string; type?: 'text' | 'email' | 'password' | 'url'; placeholder?: string; defaultValue?: string; value?: string; onChange?: React.ChangeEventHandler<HTMLInputElement>; error?: string; hint?: string; mono?: boolean; icon?: string; readOnly?: boolean; autoComplete?: string; id?: string }
export declare function TextField(props: TextFieldProps): React.ReactElement;
export interface SwitchProps { checked?: boolean; defaultChecked?: boolean; onChange?: (on: boolean) => void; label?: string; disabled?: boolean; 'aria-label'?: string }
export declare function Switch(props: SwitchProps): React.ReactElement;
export interface FilterChipProps { selected?: boolean; count?: number; icon?: string; menu?: boolean; onClick?: () => void; children: React.ReactNode }
export declare function FilterChip(props: FilterChipProps): React.ReactElement;
export interface StatusBadgeProps { status: Status | string; children?: React.ReactNode }
export declare function StatusBadge(props: StatusBadgeProps): React.ReactElement;
export interface StatusReasonProps { reason: Reason | null; compact?: boolean; lastSeen?: string; action?: React.ReactNode }
export declare function StatusReason(props: StatusReasonProps): React.ReactElement | null;
export interface ConnectionBannerProps { state: 'live' | 'reconnecting' | 'offline'; onRetry?: () => void; children?: React.ReactNode }
export declare function ConnectionBanner(props: ConnectionBannerProps): React.ReactElement;
export interface CameraCardProps { name: string; location?: string | null; status: Status; reason?: Reason | null; enabled?: boolean; lastEventAt?: string; lastSeen?: string; thumb?: string | null; canControl?: boolean; onToggle?: (on: boolean) => void }
export declare function CameraCard(props: CameraCardProps): React.ReactElement;
export interface EventRowProps { crop?: string | null; known: boolean; confidence?: number | null; personName?: string; cameraName: string; time: string; seenToday?: number; isNew?: boolean; onClick?: () => void }
export declare function EventRow(props: EventRowProps): React.ReactElement;
export interface FrameViewerProps { src?: string | null; naturalWidth?: number; naturalHeight?: number; bbox?: [number, number, number, number] | null; label?: string; time?: string; alt?: string }
export declare function FrameViewer(props: FrameViewerProps): React.ReactElement;
export interface StatTileProps { label: string; value: React.ReactNode; total?: number; sub?: string; subTone?: 'online' | 'warn' | 'danger' }
export declare function StatTile(props: StatTileProps): React.ReactElement;
export interface HourlyChartProps { data: number[]; nowHour?: number; title?: string }
export declare function HourlyChart(props: HourlyChartProps): React.ReactElement;
export interface ModeOptionProps { title: string; description?: string; icon?: string; tag?: string; selected?: boolean; onClick?: () => void }
export declare function ModeOption(props: ModeOptionProps): React.ReactElement;
export interface CopyFieldProps { value: string; label?: string; badge?: string; hint?: string; onCopy?: () => void }
export declare function CopyField(props: CopyFieldProps): React.ReactElement;
export interface MemberRowProps { name: string; email: string; role: 'owner' | 'admin' | 'operator' | 'viewer'; isYou?: boolean; active?: boolean; editable?: boolean }
export declare function MemberRow(props: MemberRowProps): React.ReactElement;
export interface TabBarProps { active: 'dashboard' | 'cameras' | 'events' | 'team'; hideTeam?: boolean; badges?: Partial<Record<string, number>>; items?: { id: string; label: string; icon: string }[] }
export declare function TabBar(props: TabBarProps): React.ReactElement;
export interface AppBarProps { title: string; large?: boolean; back?: boolean; actions?: { icon: string; label: string }[] }
export declare function AppBar(props: AppBarProps): React.ReactElement;
export interface IconProps { name: string; size?: number; strokeWidth?: number; label?: string; className?: string }
export declare function Icon(props: IconProps): React.ReactElement;
export interface MediaPlaceholderProps { src?: string | null; kind?: 'scene' | 'face' | 'empty'; alt?: string; className?: string; style?: React.CSSProperties }
export declare function MediaPlaceholder(props: MediaPlaceholderProps): React.ReactElement;
declare global { interface Window { OpenVision: { Button: typeof Button; TextField: typeof TextField; Switch: typeof Switch; FilterChip: typeof FilterChip; StatusBadge: typeof StatusBadge; StatusReason: typeof StatusReason; ConnectionBanner: typeof ConnectionBanner; CameraCard: typeof CameraCard; EventRow: typeof EventRow; FrameViewer: typeof FrameViewer; StatTile: typeof StatTile; HourlyChart: typeof HourlyChart; ModeOption: typeof ModeOption; CopyField: typeof CopyField; MemberRow: typeof MemberRow; TabBar: typeof TabBar; AppBar: typeof AppBar; Icon: typeof Icon; MediaPlaceholder: typeof MediaPlaceholder } } }
