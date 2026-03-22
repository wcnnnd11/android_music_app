from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="Music App API")

# 允许 Flutter 调用
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class MusicAccountCreate(BaseModel):
    platform: str
    name: str
    avatarUrl: Optional[str] = ""


class MusicAccount(BaseModel):
    id: str
    platform: str
    name: str
    avatarUrl: Optional[str] = ""


class Playlist(BaseModel):
    id: str
    accountId: str
    platform: str
    name: str
    coverUrl: Optional[str] = ""
    trackCount: int = 0


accounts_db: List[MusicAccount] = [
    MusicAccount(
        id="qq_1",
        platform="qq",
        name="QQ音乐账号",
        avatarUrl=""
    ),
    MusicAccount(
        id="netease_1",
        platform="netease",
        name="网易云账号",
        avatarUrl=""
    ),
]

playlists_db: List[Playlist] = [
    Playlist(
        id="qq_p1",
        accountId="qq_1",
        platform="qq",
        name="我喜欢的歌",
        coverUrl="",
        trackCount=52
    ),
    Playlist(
        id="qq_p2",
        accountId="qq_1",
        platform="qq",
        name="学习歌单",
        coverUrl="",
        trackCount=31
    ),
    Playlist(
        id="netease_p1",
        accountId="netease_1",
        platform="netease",
        name="深夜循环",
        coverUrl="",
        trackCount=18
    ),
]


@app.get("/health")
def health():
    return {
        "code": 0,
        "message": "ok",
        "data": {"status": "up"}
    }


@app.get("/accounts")
def get_accounts():
    return {
        "code": 0,
        "message": "success",
        "data": [item.model_dump() for item in accounts_db]
    }


@app.post("/accounts")
def create_account(payload: MusicAccountCreate):
    account_id = f"{payload.platform}_{len(accounts_db) + 1}"
    account = MusicAccount(
        id=account_id,
        platform=payload.platform,
        name=payload.name,
        avatarUrl=payload.avatarUrl or ""
    )
    accounts_db.append(account)
    return {
        "code": 0,
        "message": "success",
        "data": account.model_dump()
    }


@app.delete("/accounts/{account_id}")
def delete_account(account_id: str):
    global accounts_db, playlists_db

    target = next((item for item in accounts_db if item.id == account_id), None)
    if target is None:
        raise HTTPException(status_code=404, detail="account not found")

    accounts_db = [item for item in accounts_db if item.id != account_id]
    playlists_db = [item for item in playlists_db if item.accountId != account_id]

    return {
        "code": 0,
        "message": "success",
        "data": True
    }


@app.get("/playlists")
def get_playlists(account_id: str = Query(...)):
    items = [item.model_dump() for item in playlists_db if item.accountId == account_id]
    return {
        "code": 0,
        "message": "success",
        "data": items
    }